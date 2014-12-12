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
# Unit tests for cloud::image class
#
require 'spec_helper'

describe 'cloud::image::api' do

  let :params do
    { :glance_db_host                    => '10.0.0.1',
      :glance_db_user                    => 'glance',
      :glance_db_password                => 'secrete',
      :ks_keystone_internal_host         => '10.0.0.1',
      :ks_keystone_internal_proto        => 'https',
      :ks_glance_internal_host           => '10.0.0.1',
      :openstack_vip                     => '10.0.0.42',
      :ks_glance_api_internal_port       => '9292',
      :ks_glance_registry_internal_port  => '9191',
      :ks_glance_registry_internal_proto => 'https',
      :ks_glance_password                => 'secrete',
      :rabbit_host                       => '10.0.0.1',
      :rabbit_password                   => 'secrete',
      :glance_rbd_user                   => 'glance',
      :glance_rbd_pool                   => 'images',
      :backend                           => 'rbd',
      :debug                             => true,
      :verbose                           => true,
      :use_syslog                        => true,
      :log_facility                      => 'LOG_LOCAL0',
      :api_eth                           => '10.0.0.1'
    }
  end

  shared_examples_for 'openstack image api' do

    it 'should not configure firewall rule' do
      is_expected.not_to contain_firewall('100 allow glance api access')
    end

    it 'configure glance-api' do
      is_expected.to contain_class('glance::api').with(
        :database_connection      => 'mysql://glance:secrete@10.0.0.1/glance?charset=utf8',
        :keystone_password        => 'secrete',
        :registry_host            => '10.0.0.42',
        :registry_port            => '9191',
        :registry_client_protocol => 'https',
        :keystone_tenant          => 'services',
        :keystone_user            => 'glance',
        :show_image_direct_url    => true,
        :verbose                  => true,
        :debug                    => true,
        :auth_host                => '10.0.0.1',
        :auth_protocol            => 'https',
        :log_facility             => 'LOG_LOCAL0',
        :bind_host                => '10.0.0.1',
        :bind_port                => '9292',
        :use_syslog               => true,
        :pipeline                 => 'keystone',
        :log_dir                  => false,
        :log_file                 => false
      )
    end

    # TODO(EmilienM) Disabled for now
    # Follow-up https://github.com/enovance/puppet-openstack-cloud/issues/160
    #
    # it 'configure glance notifications with rabbitmq backend' do
    #   should contain_class('glance::notify::rabbitmq').with(
    #       :rabbit_password => 'secrete',
    #       :rabbit_userid   => 'glance',
    #       :rabbit_host     => '10.0.0.1'
    #     )
    # end
    it { is_expected.to contain_glance_api_config('DEFAULT/notifier_driver').with_value('noop') }

    it 'configure glance rbd backend' do
      is_expected.to contain_class('glance::backend::rbd').with(
          :rbd_store_pool => 'images',
          :rbd_store_user => 'glance'
        )
    end

    it 'configure crontab to clean glance cache' do
      is_expected.to contain_class('glance::cache::cleaner')
      is_expected.to contain_class('glance::cache::pruner')
    end

    context 'with file Glance backend' do
      before :each do
        params.merge!(:backend => 'file')
      end

      it 'configure Glance with file backend' do
        is_expected.to contain_class('glance::backend::file')
        is_expected.not_to contain_class('glance::backend::rbd')
        is_expected.to contain_glance_api_config('DEFAULT/filesystem_store_datadir').with('value' => '/var/lib/glance/images/')
        is_expected.to contain_glance_api_config('DEFAULT/default_store').with('value' => 'file')
      end
    end

    context 'with NFS Glance backend' do
      before :each do
        params.merge!(:backend                  => 'nfs',
                      :filesystem_store_datadir => '/srv/images/',
                      :nfs_device               => 'nfs.example.com:/vol1',
                      :nfs_options              => 'noacl,fsid=123' )
      end

      it 'configure Glance with NFS backend' do
        is_expected.to contain_class('glance::backend::file')
        is_expected.not_to contain_class('glance::backend::rbd')
        is_expected.to contain_glance_api_config('DEFAULT/filesystem_store_datadir').with('value' => '/srv/images/')
        is_expected.to contain_glance_api_config('DEFAULT/default_store').with('value' => 'file')
        is_expected.to contain_mount('/srv/images/').with({
          'ensure'  => 'mounted',
          'fstype'  => 'nfs',
          'device'  => 'nfs.example.com:/vol1',
          'options' => 'noacl,fsid=123',
        })
      end
    end

    context 'with Swift backend' do
      before :each do
        params.merge!(:backend => 'swift')
      end

      it 'configure Glance with Glance backend' do
        is_expected.not_to contain_class('glance::backend::file')
        is_expected.not_to contain_class('glance::backend::rbd')
        is_expected.to contain_glance_api_config('DEFAULT/default_store').with('value' => 'swift')
        is_expected.to contain_glance_api_config('DEFAULT/swift_store_user').with('value' => 'services:glance')
        is_expected.to contain_glance_api_config('DEFAULT/swift_store_key').with('value' => 'secrete')
        is_expected.to contain_glance_api_config('DEFAULT/swift_store_auth_address').with('value' => 'https://10.0.0.1:35357/v2.0/')
        is_expected.to contain_glance_api_config('DEFAULT/swift_store_create_container_on_put').with('value' => true)
      end
    end

    context 'with missing parameter when using Glance NFS backend' do
      before :each do
        params.merge!(:backend    => 'nfs',
                      :nfs_device => false )
      end
      it { is_expected.to compile.and_raise_error(/When running NFS backend, you need to provide nfs_device parameter./) }
    end

    context 'with wrong Glance backend' do
      before :each do
        params.merge!(:backend => 'Something')
      end
      it { is_expected.to compile.and_raise_error(/Something is not a Glance supported backend./) }
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure Glance API firewall rules' do
        is_expected.to contain_firewall('100 allow glance-api access').with(
          :port   => '9292',
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
      it 'configure Glance API firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow glance-api access').with(
          :port   => '9292',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily  => 'Debian',
        # required for rpcbind module
        :lsbdistid => 'Debian' }
    end

    it_configures 'openstack image api'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily          => 'RedHat',
        # required for nfs module
        :lsbmajdistrelease => '7' }
    end

    it_configures 'openstack image api'
  end

end
