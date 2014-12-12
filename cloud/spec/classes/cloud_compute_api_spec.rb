#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cloud::compute::api class
#

require 'spec_helper'

describe 'cloud::compute::api' do

  shared_examples_for 'openstack compute api' do

    let :pre_condition do
      "class { 'cloud::compute':
        availability_zone       => 'MyZone',
        nova_db_host            => '10.0.0.1',
        nova_db_use_slave       => false,
        nova_db_user            => 'nova',
        nova_db_password        => 'secrete',
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete',
        ks_glance_internal_host => '10.0.0.1',
        glance_api_port         => '9292',
        verbose                 => true,
        debug                   => true,
        use_syslog              => true,
        neutron_protocol        => 'http',
        neutron_endpoint        => '10.0.0.1',
        neutron_region_name     => 'MyRegion',
        neutron_password        => 'secrete',
        memcache_servers        => ['10.0.0.1','10.0.0.2'],
        log_facility            => 'LOG_LOCAL0' }"
    end

    let :params do
      { :ks_keystone_internal_host            => '127.0.0.1',
        :ks_keystone_internal_proto           => 'https',
        :ks_nova_password                     => 'novapassword',
        :api_eth                              => '127.0.0.1',
        :ks_ec2_public_port                   => '8773',
        :ks_nova_public_port                  => '8774',
        :ks_metadata_public_port              => '8775',
        :neutron_metadata_proxy_shared_secret => 'metadatapassword' }
    end

    it 'configure nova common' do
      is_expected.to contain_class('nova').with(
          :verbose                 => true,
          :debug                   => true,
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0',
          :rabbit_userid           => 'nova',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :memcached_servers       => ['10.0.0.1','10.0.0.2'],
          :database_connection     => 'mysql://nova:secrete@10.0.0.1/nova?charset=utf8',
          :glance_api_servers      => 'http://10.0.0.1:9292',
          :log_dir                 => false
        )
      is_expected.to contain_nova_config('DEFAULT/resume_guests_state_on_host_boot').with('value' => true)
      is_expected.to contain_nova_config('DEFAULT/default_availability_zone').with('value' => 'MyZone')
      is_expected.to contain_nova_config('DEFAULT/servicegroup_driver').with_value('mc')
      is_expected.to contain_nova_config('DEFAULT/glance_num_retries').with_value('10')
    end

    it 'does not configure nova db slave' do
        is_expected.to contain_nova_config('database/slave_connection').with('ensure' => 'absent')
    end

    context "when enabling nova db slave" do
      let :pre_condition do
        "class { 'cloud::compute':
          nova_db_host            => '10.0.0.1',
          nova_db_use_slave       => true,
          nova_db_user            => 'nova',
          nova_db_password        => 'secrete' }"
      end
      it 'configure nova db slave' do
          is_expected.to contain_nova_config('database/slave_connection').with(
              'value' => 'mysql://nova:secrete@10.0.0.1:3307/nova?charset=utf8')
      end
    end

    it 'configure neutron on compute node' do
      is_expected.to contain_class('nova::network::neutron').with(
          :neutron_admin_password => 'secrete',
          :neutron_admin_auth_url => 'http://10.0.0.1:35357/v2.0',
          :neutron_region_name    => 'MyRegion',
          :neutron_url            => 'http://10.0.0.1:9696'
        )
    end

    it 'checks if Nova DB is populated' do
      is_expected.to contain_exec('nova_db_sync').with(
        :command => 'nova-manage db sync',
        :user    => 'nova',
        :path    => '/usr/bin',
        :unless  => '/usr/bin/mysql nova -h 10.0.0.1 -u nova -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure nova-api' do
      is_expected.to contain_class('nova::api').with(
          :enabled                              => true,
          :auth_host                            => '127.0.0.1',
          :auth_protocol                        => 'https',
          :admin_password                       => 'novapassword',
          :api_bind_address                     => '127.0.0.1',
          :metadata_listen                      => '127.0.0.1',
          :neutron_metadata_proxy_shared_secret => 'metadatapassword',
          :osapi_v3                             => true
        )
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure nova firewall rules' do
        is_expected.to contain_firewall('100 allow nova-api access').with(
          :port   => '8774',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow nova-ec2 access').with(
          :port   => '8773',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow nova-metadata access').with(
          :port   => '8775',
          :proto  => 'tcp',
          :action => 'accept',
        )
      end
    end

    context 'with custom firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      before :each do
        params.merge!(:firewall_settings => { 'limit' => '50/sec' } )
      end
      it 'configure nova firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow nova-api access').with(
          :port   => '8774',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow nova-ec2 access').with(
          :port   => '8773',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow nova-metadata access').with(
          :port   => '8775',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack compute api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'openstack compute api'
  end

end
