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
# Unit tests for cloud::orchestration::engine class
#

require 'spec_helper'

describe 'cloud::orchestration::engine' do

  shared_examples_for 'openstack orchestration engine' do

    let :pre_condition do
      "class { 'cloud::orchestration':
        rabbit_hosts               => ['10.0.0.1'],
        rabbit_password            => 'secrete',
        ks_keystone_internal_host  => '10.0.0.1',
        ks_keystone_internal_port  => '5000',
        ks_keystone_internal_proto => 'http',
        ks_keystone_admin_host     => '10.0.0.1',
        ks_keystone_admin_port     => '5000',
        ks_keystone_admin_proto    => 'http',
        ks_heat_public_host        => '10.0.0.1',
        ks_heat_public_proto       => 'http',
        ks_heat_password           => 'secrete',
        heat_db_host               => '10.0.0.1',
        heat_db_user               => 'heat',
        heat_db_password           => 'secrete',
        verbose                    => true,
        log_facility               => 'LOG_LOCAL0',
        use_syslog                 => true,
        debug                      => true,
        os_endpoint_type           => 'internalURL' }"
    end

    let :params do
      { :enabled                        => true,
        :auth_encryption_key            => 'secrete',
        :ks_heat_public_host            => '10.0.0.1',
        :ks_heat_public_proto           => 'http',
        :ks_heat_cfn_public_port        => '8000',
        :ks_heat_cloudwatch_public_port => '8003',
        :ks_heat_password               => 'secrete' }
    end

    it 'configure heat common' do
      is_expected.to contain_class('heat').with(
          :verbose                 => true,
          :debug                   => true,
          :log_facility            => 'LOG_LOCAL0',
          :use_syslog              => true,
          :rabbit_userid           => 'heat',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :keystone_host           => '10.0.0.1',
          :keystone_port           => '5000',
          :keystone_protocol       => 'http',
          :keystone_password       => 'secrete',
          :auth_uri                => 'http://10.0.0.1:5000/v2.0',
          :keystone_ec2_uri        => 'http://10.0.0.1:5000/v2.0/ec2tokens',
          :sql_connection          => 'mysql://heat:secrete@10.0.0.1/heat?charset=utf8',
          :log_dir                 => false
        )
      is_expected.to contain_heat_config('clients/endpoint_type').with('value' => 'internalURL')
    end

    it 'configure heat engine' do
      is_expected.to contain_class('heat::engine').with(
          :enabled                       => true,
          :auth_encryption_key           => 'secrete',
          :heat_metadata_server_url      => 'http://10.0.0.1:8000',
          :heat_waitcondition_server_url => 'http://10.0.0.1:8000/v1/waitcondition',
          :heat_watch_server_url         => 'http://10.0.0.1:8003',
          :deferred_auth_method          => 'password',
        )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack orchestration engine'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack orchestration engine'
  end

end
