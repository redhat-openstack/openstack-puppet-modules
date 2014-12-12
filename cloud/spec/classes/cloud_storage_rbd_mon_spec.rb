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
# Unit tests for cloud::storage::rbd::monitor class
#

require 'spec_helper'

describe 'cloud::storage::rbd::monitor' do

  shared_examples_for 'ceph monitor' do

    let :pre_condition do
      "class { 'cloud::storage::rbd':
        fsid            => '123',
        cluster_network => '10.0.0.0/24',
        public_network  => '192.168.0.0/24' }"
    end

    let :params do
      { :mon_addr       => '10.0.0.1',
        :monitor_secret => 'secret' }
    end

    it 'configure ceph common' do
      is_expected.to contain_class('ceph::conf').with(
        :fsid            => '123',
        :auth_type       => 'cephx',
        :cluster_network => '10.0.0.0/24',
        :public_network  => '192.168.0.0/24',
        :enable_service  => true
      )
    end

    it 'configure ceph mon' do
      is_expected.to contain_ceph__mon('123').with(
        :monitor_secret => 'secret',
        :mon_port       => '6789',
        :mon_addr       => '10.0.0.1'
      )
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure ceph monitor firewall rules' do
        is_expected.to contain_firewall('100 allow ceph-mon access').with(
          :port   => '6789',
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
      it 'configure ceph monitor firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow ceph-mon access').with(
          :port   => '6789',
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

    it_configures 'ceph monitor'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end
    it_configures 'ceph monitor'
  end

end
