#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# Unit tests for trove::api
#
require 'spec_helper'

describe 'trove::api' do

  let :params do
    { :keystone_password     => 'passw0rd',
      :auth_host             => '10.0.0.10',
      :auth_url              => 'http://10.0.0.10:5000/v2.0',
      :auth_port             => '35357',
      :auth_protocol         => 'https',
      :keystone_tenant       => '_services_',
      :keystone_user         => 'trove',
    }
  end

  shared_examples 'trove-api' do

    context 'with default parameters' do

      let :pre_condition do
        "class { 'trove':
         nova_proxy_admin_pass => 'verysecrete'}"
      end

      it 'installs trove-api package and service' do
        should contain_service('trove-api').with(
          :name      => platform_params[:api_service_name],
          :ensure    => 'running',
          :hasstatus => true,
          :enable    => true
        )
        should contain_package('trove-api').with(
          :name   => platform_params[:api_package_name],
          :ensure => 'present',
          :notify => 'Service[trove-api]'
        )
      end

      it 'configures trove-api with default parameters' do
        should contain_trove_config('DEFAULT/verbose').with_value(false)
        should contain_trove_config('DEFAULT/debug').with_value(false)
        should contain_trove_config('DEFAULT/bind_host').with_value('0.0.0.0')
        should contain_trove_config('DEFAULT/bind_port').with_value('8779')
        should contain_trove_config('DEFAULT/backlog').with_value('4096')
        should contain_trove_config('DEFAULT/trove_api_workers').with_value('8')
        should contain_trove_config('DEFAULT/trove_auth_url').with_value('http://10.0.0.10:5000/v2.0')
        should contain_trove_config('DEFAULT/nova_proxy_admin_user').with_value('admin')
        should contain_trove_config('DEFAULT/nova_proxy_admin_pass').with_value('verysecrete')
        should contain_trove_config('DEFAULT/nova_proxy_admin_tenant_name').with_value('admin')
        should contain_trove_config('keystone_authtoken/auth_host').with_value('10.0.0.10')
        should contain_trove_config('keystone_authtoken/auth_port').with_value('35357')
        should contain_trove_config('keystone_authtoken/auth_protocol').with_value('https')
        should contain_trove_config('keystone_authtoken/admin_tenant_name').with_value('_services_')
        should contain_trove_config('keystone_authtoken/admin_user').with_value('trove')
        should contain_trove_config('keystone_authtoken/admin_password').with_value('passw0rd')
      end

      context 'when using a single RabbitMQ server' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_host           => '10.0.0.1'}"
        end
        it 'configures trove-api with RabbitMQ' do
          should contain_trove_config('DEFAULT/rabbit_host').with_value('10.0.0.1')
        end
      end

      context 'when using multiple RabbitMQ servers' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             rabbit_hosts          => ['10.0.0.1','10.0.0.2']}"
        end
        it 'configures trove-api with RabbitMQ' do
          should contain_trove_config('DEFAULT/rabbit_hosts').with_value(['10.0.0.1,10.0.0.2'])
        end
      end

      context 'when using MySQL' do
        let :pre_condition do
          "class { 'trove':
             nova_proxy_admin_pass => 'verysecrete',
             database_connection   => 'mysql://trove:pass@10.0.0.1/trove'}"
        end
        it 'configures trove-api with RabbitMQ' do
          should contain_trove_config('DEFAULT/sql_connection').with_value('mysql://trove:pass@10.0.0.1/trove')
        end
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => 8 }
    end

    let :platform_params do
      { :api_package_name => 'trove-api',
        :api_service_name => 'trove-api' }
    end

    it_configures 'trove-api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => 8 }
    end

    let :platform_params do
      { :api_package_name => 'openstack-trove-api',
        :api_service_name => 'openstack-trove-api' }
    end

    it_configures 'trove-api'
  end

end
