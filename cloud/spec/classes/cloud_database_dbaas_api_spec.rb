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
# Unit tests for cloud::database::dbaas::api class
#

require 'spec_helper'

describe 'cloud::database::dbaas::api' do

  shared_examples_for 'openstack database dbaas api' do

    let :pre_condition do
      "class { 'cloud::database::dbaas':
        trove_db_host           => '10.0.0.1',
        trove_db_user           => 'trove',
        trove_db_password       => 'secrete',
        nova_admin_username     => 'trove',
        nova_admin_password     => 'trovepassword',
        nova_admin_tenant_name  => 'services',
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete' }"
    end

    let :params do
      { :ks_keystone_internal_host  => '10.0.0.1',
        :ks_keystone_internal_proto => 'https',
        :ks_trove_password          => 'trovepassword',
        :api_eth                    => '10.0.0.1',
        :debug                      => true,
        :verbose                    => true,
        :use_syslog                 => true,
        :ks_trove_public_port       => '8779' }
    end

    it 'configure trove common' do
      is_expected.to contain_class('trove').with(
          :rabbit_userid                => 'trove',
          :rabbit_hosts                 => ['10.0.0.1'],
          :rabbit_password              => 'secrete',
          :rabbit_virtual_host          => '/',
          :nova_proxy_admin_pass        => 'trovepassword',
          :nova_proxy_admin_user        => 'trove',
          :nova_proxy_admin_tenant_name => 'services',
          :database_connection          => 'mysql://trove:secrete@10.0.0.1/trove?charset=utf8',
        )
    end

    it 'configure trove api' do
      is_expected.to contain_class('trove::api').with(
        :verbose           => true,
        :debug             => true,
        :use_syslog        => true,
        :bind_host         => '10.0.0.1',
        :bind_port         => '8779',
        :auth_url          => 'https://10.0.0.1:5000/v2.0',
        :keystone_password => 'trovepassword'
      )
    end

    it 'checks if Trove DB is populated' do
      is_expected.to contain_exec('trove_db_sync').with(
        :command => 'trove-manage db_sync',
        :user    => 'trove',
        :path    => '/usr/bin',
        :unless  => '/usr/bin/mysql trove -h 10.0.0.1 -u trove -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure trove-api firewall rules' do
        is_expected.to contain_firewall('100 allow trove-api access').with(
          :port   => '8779',
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
      it 'configure trove-api firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow trove-api access').with(
          :port   => '8779',
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

    it_configures 'openstack database dbaas api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'openstack database dbaas api'
  end

end
