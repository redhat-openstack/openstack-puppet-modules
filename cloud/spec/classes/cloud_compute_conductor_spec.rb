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
# Unit tests for cloud::compute::conductor class
#

require 'spec_helper'

describe 'cloud::compute::conductor' do

  shared_examples_for 'openstack compute conductor' do

    let :pre_condition do
      "class { 'cloud::compute':
        availability_zone       => 'MyZone',
        nova_db_host            => '10.0.0.1',
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

    it 'configure nova-conductor' do
      is_expected.to contain_class('nova::conductor').with(:enabled => true)
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack compute conductor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'openstack compute conductor'
  end

end
