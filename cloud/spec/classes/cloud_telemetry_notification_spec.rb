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
# Unit tests for cloud::telemetry::notification class
#

require 'spec_helper'

describe 'cloud::telemetry::notification' do

  shared_examples_for 'openstack telemetry notification' do

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

    it 'configure ceilometer notification agent' do
      is_expected.to contain_class('ceilometer::agent::notification')
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian',
        :hostname => 'node1' }
    end

    it_configures 'openstack telemetry notification'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat',
        :hostname => 'node1' }
    end

    it_configures 'openstack telemetry notification'
  end

end
