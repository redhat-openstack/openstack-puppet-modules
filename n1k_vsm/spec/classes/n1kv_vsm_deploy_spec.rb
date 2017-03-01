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

describe 'n1k_vsm::deploy' do

  let :params do
    {  }
  end

  shared_examples_for 'n1k vsm deploy' do

    context 'for primary role' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           vsm_role          => 'primary',
           pacemaker_control => false,
         }"
      end

      it 'creates disk' do
        is_expected.to contain_exec('Exec_create_disk').with(
          'creates'  => '/var/spool/cisco/vsm/primary_disk',
        )
      end

      it 'creates xml' do
        is_expected.to contain_file('File_Target_XML_File').with(
          'path'  => '/var/spool/cisco/vsm/vsm_primary_deploy.xml',
        )
      end

      it 'defines vsm' do
        is_expected.to contain_exec('Exec_Define_VSM').with(
          'command' => '/usr/bin/virsh define /var/spool/cisco/vsm/vsm_primary_deploy.xml',
        )
      end

      it 'launches vsm' do
        is_expected.to contain_exec('Exec_Launch_VSM').with(
          'command' => '/usr/bin/virsh start vsm-p',
        )
      end
    end

    context 'for secondary role' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           vsm_role          => 'secondary',
           pacemaker_control => false,
         }"
      end

      it 'creates disk' do
        is_expected.to contain_exec('Exec_create_disk').with(
          'creates'  => '/var/spool/cisco/vsm/secondary_disk',
        )
      end

      it 'creates xml' do
        is_expected.to contain_file('File_Target_XML_File').with(
          'path'  => '/var/spool/cisco/vsm/vsm_secondary_deploy.xml',
        )
      end

      it 'defines vsm' do
        is_expected.to contain_exec('Exec_Define_VSM').with(
          'command' => '/usr/bin/virsh define /var/spool/cisco/vsm/vsm_secondary_deploy.xml',
        )
      end

      it 'launches vsm' do
        is_expected.to contain_exec('Exec_Launch_VSM').with(
          'command' => '/usr/bin/virsh start vsm-s',
        )
      end
    end

    context 'for pacemaker controlled' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           vsm_role          => 'primary',
           pacemaker_control => true,
         }"
      end

      it 'creates disk' do
        is_expected.to contain_exec('Exec_create_disk').with(
          'creates'  => '/var/spool/cisco/vsm/primary_disk',
        )
      end

      it 'creates xml' do
        is_expected.to contain_file('File_Target_XML_File').with(
          'path'  => '/var/spool/cisco/vsm/vsm_primary_deploy.xml',
        )
      end

      it 'creates secondary disk' do
        is_expected.to contain_exec('Exec_create_disk_Secondary').with(
          'creates'  => '/var/spool/cisco/vsm/secondary_disk',
        )
      end

      it 'creates secondary xml' do
        is_expected.to contain_file('File_Target_XML_File_Secondary').with(
          'path'  => '/var/spool/cisco/vsm/vsm_secondary_deploy.xml',
        )
      end

    end

  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'n1k vsm deploy'
  end

end

