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
# Unit tests for cloud::object::storage class
#

require 'spec_helper'

describe 'cloud::object::storage' do

  shared_examples_for 'openstack storage configuration' do
    let :params do
      { :storage_eth           => '127.0.0.1',
        :swift_zone            => 'undef',
        :object_port           => '6000',
        :container_port        => '6001',
        :account_port          => '6002',
        :fstype                => 'xfs',
        :device_config_hash    => {'sdc' => {}, 'sdd' => {}},
        :ring_container_device => 'sdb',
        :ring_account_device   => 'sdb' }
    end

    it 'create and configure storage server' do

      is_expected.to contain_class('swift::storage').with({
        'storage_local_net_ip' => '127.0.0.1',
      })

      is_expected.to contain_swift__storage__server('6000').with({
        'type'                   => 'object',
        'config_file_path'       => 'object-server.conf',
        'log_facility'           => 'LOG_LOCAL6',
        'pipeline'               => ['healthcheck', 'recon', 'object-server'],
        'storage_local_net_ip'  => '127.0.0.1',
        'replicator_concurrency' => '2',
        'updater_concurrency'    => '1',
        'reaper_concurrency'     => '1',
        'mount_check'            => 'true',
        'require'                => 'Class[Swift]',
      })

      is_expected.to contain_swift__storage__server('6001').with({
        'type'                   => 'container',
        'config_file_path'       => 'container-server.conf',
        'log_facility'           => 'LOG_LOCAL4',
        'pipeline'               => ['healthcheck', 'container-server'],
        'storage_local_net_ip'  => '127.0.0.1',
        'replicator_concurrency' => '2',
        'updater_concurrency'    => '1',
        'reaper_concurrency'     => '1',
        'mount_check'            => 'true',
        'require'                => 'Class[Swift]',
      })

      is_expected.to contain_swift__storage__server('6002').with({
        'type'                   => 'account',
        'config_file_path'       => 'account-server.conf',
        'log_facility'           => 'LOG_LOCAL2',
        'pipeline'               => ['healthcheck', 'account-server'],
        'storage_local_net_ip'  => '127.0.0.1',
        'replicator_concurrency' => '2',
        'updater_concurrency'    => '1',
        'reaper_concurrency'     => '1',
        'mount_check'            => 'true',
        'require'                => 'Class[Swift]',
      })

    end

    it 'create and configure the hard drive' do
      is_expected.to contain_swift__storage__xfs('sdc')
      is_expected.to contain_swift__storage__xfs('sdd')
      is_expected.to contain_cloud__object__set_io_scheduler('sdc')
      is_expected.to contain_cloud__object__set_io_scheduler('sdd')
    end

    ['account', 'container', 'object'].each do |swift_component|
      it "configures #{swift_component} filter" do
        is_expected.to contain_swift__storage__filter__recon(swift_component)
        is_expected.to contain_swift__storage__filter__healthcheck(swift_component)
      end
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure swift-storage firewall rules' do
        is_expected.to contain_firewall('100 allow swift-container access').with(
          :port   => '6001',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow swift-account access').with(
          :port   => '6002',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow swift-object access').with(
          :port   => '6000',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow swift rsync access').with(
          :port   => '873',
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
      it 'configure swift-storage firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow swift-container access').with(
          :port   => '6001',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow swift-account access').with(
          :port   => '6002',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow swift-object access').with(
          :port   => '6000',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow swift rsync access').with(
          :port   => '873',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      {
        :osfamily        => 'Debian' ,
      }
    end

    it_configures 'openstack storage configuration'
  end

  context 'on RedHat platforms' do
    let :facts do
      {
        :osfamily       => 'RedHat'
      }
    end
    it_configures 'openstack storage configuration'
  end
end
