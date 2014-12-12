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
# Unit tests for cloud::telemetry::api class
#

require 'spec_helper'

describe 'cloud::telemetry::api' do

  shared_examples_for 'openstack telemetry api' do

    let :pre_condition do
      "class { 'cloud::telemetry':
        ceilometer_secret          => 'secrete',
        rabbit_hosts               => ['10.0.0.1'],
        rabbit_password            => 'secrete',
        ks_keystone_internal_host  => '10.0.0.1',
        ks_keystone_internal_port  => '5000',
        ks_keystone_internal_proto => 'http',
        ks_ceilometer_password     => 'secrete',
        region                     => 'MyRegion',
        log_facility               => 'LOG_LOCAL0',
        use_syslog                 => true,
        verbose                    => true,
        debug                      => true }"
    end

    let :params do
      { :ks_keystone_internal_host            => '127.0.0.1',
        :ks_keystone_internal_proto           => 'http',
        :ks_ceilometer_internal_port          => '8777',
        :ks_ceilometer_password               => 'rabbitpassword',
        :api_eth                              => '127.0.0.1' }
    end

    it 'configure ceilometer common' do
      is_expected.to contain_class('ceilometer').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'ceilometer',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :metering_secret         => 'secrete',
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0',
          :log_dir                 => false
        )
      is_expected.to contain_class('ceilometer::agent::auth').with(
          :auth_password => 'secrete',
          :auth_url      => 'http://10.0.0.1:5000/v2.0',
          :auth_region   => 'MyRegion'
        )
    end

    it 'configure ceilometer-api' do
      is_expected.to contain_class('ceilometer::api').with(
          :keystone_password => 'rabbitpassword',
          :keystone_host     => '127.0.0.1',
          :keystone_protocol => 'http',
          :host              => '127.0.0.1'
        )
    end

    it 'configure ceilometer-expirer' do
      is_expected.to contain_class('ceilometer::expirer').with(
          :time_to_live => '2592000',
          :minute       => '0',
          :hour         => '0'
        )
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure ceilometer firewall rules' do
        is_expected.to contain_firewall('100 allow ceilometer-api access').with(
          :port   => '8777',
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
      it 'configure ceilometer firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow ceilometer-api access').with(
          :port   => '8777',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian',
        :hostname => 'node1' }
    end

    it_configures 'openstack telemetry api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :hostname => 'node1' }
    end

    it_configures 'openstack telemetry api'
  end

end
