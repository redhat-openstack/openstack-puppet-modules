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
# Unit tests for cloud::volume::controller class
#

require 'spec_helper'

describe 'cloud::volume::scheduler' do

  shared_examples_for 'openstack volume scheduler' do

    let :pre_condition do
      "class { 'cloud::volume':
        cinder_db_host             => '10.0.0.1',
        cinder_db_user             => 'cinder',
        cinder_db_password         => 'secrete',
        rabbit_hosts               => ['10.0.0.1'],
        rabbit_password            => 'secrete',
        verbose                    => true,
        debug                      => true,
        log_facility               => 'LOG_LOCAL0',
        storage_availability_zone  => 'nova',
        use_syslog                 => true,
        nova_endpoint_type         => 'internalURL' }"
    end

    let :params do
      {}
    end

    it 'configure cinder common' do
      is_expected.to contain_class('cinder').with(
          :verbose                   => true,
          :debug                     => true,
          :rabbit_userid             => 'cinder',
          :rabbit_hosts              => ['10.0.0.1'],
          :rabbit_password           => 'secrete',
          :rabbit_virtual_host       => '/',
          :log_facility              => 'LOG_LOCAL0',
          :use_syslog                => true,
          :log_dir                   => false,
          :storage_availability_zone => 'nova'
        )
      is_expected.to contain_class('cinder::ceilometer')
      is_expected.to contain_cinder_config('DEFAULT/nova_catalog_info').with('value' => 'compute:nova:internalURL')
    end

    it 'checks if Cinder DB is populated' do
      is_expected.to contain_exec('cinder_db_sync').with(
        :command => 'cinder-manage db sync',
        :user    => 'cinder',
        :path    => '/usr/bin',
        :unless  => '/usr/bin/mysql cinder -h 10.0.0.1 -u cinder -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure cinder scheduler' do
      is_expected.to contain_class('cinder::scheduler').with(
        :scheduler_driver => 'cinder.scheduler.filter_scheduler.FilterScheduler'
      )
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack volume scheduler'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack volume scheduler'
  end

end
