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
# Unit tests for cloud::volume::api class
#

require 'spec_helper'

describe 'cloud::volume::api' do

  shared_examples_for 'openstack volume api' do

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
      { :ks_cinder_password          => 'secrete',
        :ks_cinder_internal_port     => '8776',
        :ks_keystone_internal_host   => '10.0.0.1',
        :ks_keystone_internal_proto  => 'https',
        :ks_glance_internal_host     => '10.0.0.2',
        :ks_glance_api_internal_port => '9292',
        :default_volume_type         => 'ceph',
        # TODO(EmilienM) Disabled for now: http://git.io/kfTmcA
        #:backup_ceph_user            => 'cinder',
        #:backup_ceph_pool            => 'ceph_backup_cinder',
        :api_eth                     => '10.0.0.1' }
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

    it 'configure cinder glance backend' do
      is_expected.to contain_class('cinder::glance').with(
          :glance_api_servers     => 'http://10.0.0.2:9292',
          :glance_request_timeout => '10',
          :glance_num_retries     => '10'
        )
    end

    it 'configure cinder api' do
      is_expected.to contain_class('cinder::api').with(
          :keystone_password      => 'secrete',
          :keystone_auth_host     => '10.0.0.1',
          :keystone_auth_protocol => 'https',
          :bind_host              => '10.0.0.1',
          :default_volume_type    => 'ceph',
        )
    end

    context 'without default volume type' do
      before :each do
        params.delete(:default_volume_type)
      end
      it 'should raise an error and fail' do
        is_expected.not_to compile
      end
    end

    # TODO(EmilienM) Disabled for now: http://git.io/kfTmcA
    #it 'configure cinder backup using ceph backend' do
    #  should contain_class('cinder::backup')
    #  should contain_class('cinder::backup::ceph').with(
    #      :backup_ceph_user => 'cinder',
    #      :backup_ceph_pool => 'ceph_backup_cinder'
    #    )
    #end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure cinder firewall rules' do
        is_expected.to contain_firewall('100 allow cinder-api access').with(
          :port   => '8776',
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
      it 'configure cinder firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow cinder-api access').with(
          :port   => '8776',
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

    it_configures 'openstack volume api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack volume api'
  end

end
