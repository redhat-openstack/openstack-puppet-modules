#
# Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
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

require 'spec_helper'

describe 'n1k_vsm::vsmprep' do

  let :params do
    { }
  end

  shared_examples_for 'n1k vsm prep' do

    context 'with default values' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
         }"
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end
    end

    context 'with custom values' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => '5.2.1.SK3.2.2a-1',
         }"
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end
    end

  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'n1k vsm prep'
  end

end
