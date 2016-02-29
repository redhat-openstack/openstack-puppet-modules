#
# Copyright (C) 2016 Keith Schincke
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Author: Keith Schincke <keith.schincke@gmail.com>
#
require 'spec_helper'

describe 'ceph::rgw' do

  let :pre_condition do
    'include ceph::params'
  end

  shared_examples_for 'ceph rgw civetweb' do

    describe "activated with civetweb params" do
      let :title do
        'radosgw.civetweb'
      end
      let :params do
      {
        :frontend_type => 'civetweb',
      }
      end
      it { is_expected.to contain_ceph_config('client.radosgw.civetweb/user').with_value("#{default_params[:user]}") }
      it { is_expected.to contain_ceph_config('client.radosgw.civetweb/host').with_value('myhost') }
      it { is_expected.to contain_ceph_config('client.radosgw.civetweb/keyring').with_value('/etc/ceph/ceph.client.radosgw.civetweb.keyring') }
      it { is_expected.to contain_ceph_config('client.radosgw.civetweb/log_file').with_value('/var/log/ceph/radosgw.log') }
      it { is_expected.to_not contain_ceph_config('client.radosgw.civetweb/rgw_frontends') }
    end

    describe "activated with custom civetweb params" do
      let :title do
        'custom.civetweb'
      end
      let :params do
      {
        :frontend_type => 'civetweb',
        :rgw_frontends => 'civetweb port=7481',
        :user          => 'root',
      }
      end
      #it { is_expected.to contain_ceph_config('client.custom.civetweb/rgw_frontends').with_value('civetweb port=7481') }
      #it { is_expected.to contain_ceph_config('client.custom.civetweb/rgw_frontends') }
      it { is_expected.to contain_ceph_config('client.custom.civetweb/user').with_value('root') }
      it { is_expected.to contain_ceph_config('client.custom.civetweb/host').with_value('myhost') }
      it { is_expected.to contain_ceph_config('client.custom.civetweb/keyring').with_value('/etc/ceph/ceph.client.custom.civetweb.keyring') }
      it { is_expected.to contain_ceph_config('client.custom.civetweb/log_file').with_value('/var/log/ceph/radosgw.log') }
    end

  end

  describe 'Debian Family' do

    let :facts do
      {
        :concat_basedir         => '/var/lib/puppet/concat',
        :fqdn                   => 'myhost.domain',
        :hostname               => 'myhost',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Ubuntu',
        :operatingsystemrelease => '14.04',
      }
    end

    let :default_params do
      {
        :pkg_radosgw => 'radosgw',
        :user        => 'www-data',
      }
    end

    it_configures 'ceph rgw civetweb'
  end

  describe 'RedHat Family' do

    let :facts do
      {
        :concat_basedir            => '/var/lib/puppet/concat',
        :fqdn                      => 'myhost.domain',
        :hostname                  => 'myhost',
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'RedHat',
        :operatingsystemrelease    => '7.2',
        :operatingsystemmajrelease => '7',
      }
    end

    let :default_params do
      {
        :pkg_radosgw => 'ceph-radosgw',
        :user        => 'apache',
      }
    end

    it_configures 'ceph rgw civetweb'
  end

end
