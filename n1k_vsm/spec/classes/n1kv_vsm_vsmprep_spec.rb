#
# Copyright (C) 2015 Cisco Systems Inc.
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

    context 'get vsm from file' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => '5.2.1.SK3.2.2a-1',
           n1kv_source      => 'vsm_test',
           vsm_role         => 'primary',
         }"
      end

      it 'gets vsm from file' do
        is_expected.to contain_file('/var/spool/cisco/vsm/vsm_test').with(
          'source' => 'puppet:///modules/n1k_vsm/vsm_test',
        )
      end

      it 'runs repackage iso script' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script').with(
          :command => '/tmp/repackiso.py -i/var/spool/cisco/vsm/current-n1000v.iso -d1 -nvsm-p -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rprimary -f/var/spool/cisco/vsm/primary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/primary_repacked.iso'
        )
      end
    end

    context 'get vsm from specified repo' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => '5.2.1.SK3.2.2a-1',
           n1kv_source      => 'http://vsm_test',
           vsm_role         => 'primary',
         }"
      end

      it 'configures specified repo' do
        is_expected.to contain_yumrepo('cisco-vsm-repo').with(
          'baseurl' => 'http://vsm_test',
          'gpgkey'  => 'http://vsm_test/RPM-GPG-KEY'
        )
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end
      it 'runs repackage iso script' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-p -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rprimary -f/var/spool/cisco/vsm/primary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/primary_repacked.iso'
        )
      end
    end

    context 'get vsm from pre-configured repo' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => '5.2.1.SK3.2.2a-1',
           vsm_role         => 'primary',
         }"
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end

      it 'runs repackage iso script' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-p -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rprimary -f/var/spool/cisco/vsm/primary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/primary_repacked.iso'
        )
      end
    end

    context 'get vsm from pre-configured repo secondary' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => '5.2.1.SK3.2.2a-1',
           vsm_role         => 'secondary',
         }"
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end

      it 'runs repackage iso script' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-s -m0.0.0.0 -s0.0.0.0 -g0.0.0.0 -psecrete -rsecondary -f/var/spool/cisco/vsm/secondary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/secondary_repacked.iso'
        )
      end
    end

    context 'get vsm from pre-configured repo pacemaker controlled' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => '5.2.1.SK3.2.2a-1',
           pacemaker_control => true,
         }"
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end

      it 'runs rename with version' do
        is_expected.to contain_exec('Exec_VSM_Rename_with_version').with(
          :command => '/bin/cp /opt/cisco/vsm/n1000v-dk9.5.2.1.SK3.2.2a-1.iso /opt/cisco/vsm/current-n1000v.iso',
          :creates => '/opt/cisco/vsm/current-n1000v.iso'
        )
      end

      it 'runs repackage iso script' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-p -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rprimary -f/var/spool/cisco/vsm/primary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/primary_repacked.iso'
        )
      end

      it 'runs repackage iso script secondary' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script_secondary').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-s -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rsecondary -f/var/spool/cisco/vsm/secondary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/secondary_repacked.iso'
        )
      end
    end
    context 'get vsm from pre-configured repo pacemaker controlled latest version' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway      => '1.1.1.3',
           vsm_domain_id    => '1',
           vsm_admin_passwd => 'secrete',
           vsm_mgmt_ip      => '1.1.1.1',
           vsm_mgmt_netmask => '255.255.255.0',
           vsm_mgmt_gateway => '1.1.1.2',
           n1kv_version     => 'latest',
           pacemaker_control => true,
         }"
      end

      # Currently we always just check if VSM is present
      it 'installs latest n1kv sofware' do
        is_expected.to contain_package('nexus-1000v-iso').with(
          :ensure  => 'present',
        )
      end

      it 'runs rename without version' do
        is_expected.to contain_exec('Exec_VSM_Rename').with(
          :creates => '/opt/cisco/vsm/current-n1000v.iso'
        )
      end

      it 'runs repackage iso script' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-p -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rprimary -f/var/spool/cisco/vsm/primary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/primary_repacked.iso'
        )
      end

      it 'runs repackage iso script secondary' do
        is_expected.to contain_exec('Exec_VSM_Repackage_Script_secondary').with(
          :command => '/tmp/repackiso.py -i/opt/cisco/vsm/current-n1000v.iso -d1 -nvsm-s -m1.1.1.1 -s255.255.255.0 -g1.1.1.2 -psecrete -rsecondary -f/var/spool/cisco/vsm/secondary_repacked.iso',
          :creates => '/var/spool/cisco/vsm/secondary_repacked.iso'
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
