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

describe 'n1k_vsm::pkgprep_ovscfg' do

  let :params do
    {  }
  end

  shared_examples_for 'n1k vsm pkgprep_ovscfg' do

    context 'for default values' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_if_bridge     => 'eth0',
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           existing_bridge   => false,
         }"
      end
      let :facts do
        {
          :ipaddress_eth0 => '1.1.1.1',
          :osfamily => 'RedHat'
        }
      end

      it 'should require vswitch::ovs' do
         is_expected.to contain_class('vswitch::ovs')
      end

      it 'create ovs bridge' do
        is_expected.to contain_augeas('Augeas_modify_ifcfg-ovsbridge').with(
          'name'    => 'vsm-br',
          'context' => '/files/etc/sysconfig/network-scripts/ifcfg-vsm-br',
        )
      end

      it 'flap bridge' do
        is_expected.to contain_exec('Flap_n1kv_bridge').with(
          'command'  => '/sbin/ifdown vsm-br && /sbin/ifup vsm-br',
        ).that_requires('Augeas[Augeas_modify_ifcfg-ovsbridge]')
      end

      it 'attach phy if port to bridge' do
        is_expected.to contain_augeas('Augeas_modify_ifcfg-phy_if_bridge').with(
          'name'    => 'eth0',
          'context' => '/files/etc/sysconfig/network-scripts/ifcfg-eth0',
        )
      end

      it 'flap port' do
        is_expected.to contain_exec('Flap_n1kv_phy_if').with(
          'command'  => '/sbin/ifdown eth0 && /sbin/ifup eth0',
        ).that_requires('Augeas[Augeas_modify_ifcfg-phy_if_bridge]')
      end
    end

    context 'for existing bridge' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_if_bridge     => 'br_ex',
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           existing_bridge   => true,
         }"
      end
      let :facts do
        {
          :ipaddress_br_ex => '1.1.1.6',
          :osfamily        => 'RedHat'
        }
      end

      it 'should require vswitch::ovs' do
         is_expected.to contain_class('vswitch::ovs')
      end

      it 'create ovs bridge' do
        is_expected.to contain_augeas('Augeas_modify_ifcfg-ovsbridge').with(
          'name'    => 'vsm-br',
          'context' => '/files/etc/sysconfig/network-scripts/ifcfg-vsm-br',
        )
      end

      it 'flap bridge' do
        is_expected.to contain_exec('Flap_n1kv_bridge').with(
          'command'  => '/sbin/ifdown vsm-br && /sbin/ifup vsm-br',
        ).that_requires('Augeas[Augeas_modify_ifcfg-ovsbridge]')
      end

      it 'create patch port on existing bridge' do
        is_expected.to contain_exec('Create_patch_port_on_existing_bridge').with(
          'command' => '/bin/ovs-vsctl --may-exist add-port br_ex br_ex-vsm-br -- set Interface br_ex-vsm-br type=patch options:peer=vsm-br-br_ex'
        ).that_requires('Exec[Flap_n1kv_bridge]')
      end

      it 'create patch port on vsm bridge' do
        is_expected.to contain_exec('Create_patch_port_on_vsm_bridge').with(
          'command' => '/bin/ovs-vsctl --may-exist add-port vsm-br vsm-br-br_ex -- set Interface vsm-br-br_ex type=patch options:peer=br_ex-vsm-br'
        ).that_requires('Exec[Flap_n1kv_bridge]')
      end
    end

    context 'for existing bridge no ip' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_if_bridge     => 'br_ex',
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           existing_bridge   => true,
         }"
      end
      let :facts do
        {
          :osfamily        => 'RedHat'
        }
      end

      it 'should require vswitch::ovs' do
         is_expected.to contain_class('vswitch::ovs')
      end

      it 'create ovs bridge' do
        is_expected.to contain_augeas('Augeas_modify_ifcfg-ovsbridge').with(
          'name'    => 'vsm-br',
          'context' => '/files/etc/sysconfig/network-scripts/ifcfg-vsm-br',
        )
      end

      it 'flap bridge' do
        is_expected.to contain_exec('Flap_n1kv_bridge').with(
          'command'  => '/sbin/ifdown vsm-br && /sbin/ifup vsm-br',
        ).that_requires('Augeas[Augeas_modify_ifcfg-ovsbridge]')
      end

      it 'create patch port on existing bridge' do
        is_expected.to contain_exec('Create_patch_port_on_existing_bridge').with(
          'command' => '/bin/ovs-vsctl --may-exist add-port br_ex br_ex-vsm-br -- set Interface br_ex-vsm-br type=patch options:peer=vsm-br-br_ex'
        ).that_requires('Exec[Flap_n1kv_bridge]')
      end

      it 'create patch port on vsm bridge' do
        is_expected.to contain_exec('Create_patch_port_on_vsm_bridge').with(
          'command' => '/bin/ovs-vsctl --may-exist add-port vsm-br vsm-br-br_ex -- set Interface vsm-br-br_ex type=patch options:peer=br_ex-vsm-br'
        ).that_requires('Exec[Flap_n1kv_bridge]')
      end
    end

    context 'for existing bridge tagged' do
      let :pre_condition do
        "class { 'n1k_vsm':
           phy_if_bridge     => 'br_ex',
           phy_gateway       => '1.1.1.3',
           vsm_domain_id     => '1',
           vsm_admin_passwd  => 'secrete',
           vsm_mgmt_ip       => '1.1.1.1',
           vsm_mgmt_netmask  => '255.255.255.0',
           vsm_mgmt_gateway  => '1.1.1.2',
           existing_bridge   => true,
           phy_bridge_vlan   => 100,
         }"
      end
      let :facts do
        {
          :ipaddress_br_ex => '1.1.1.6',
          :osfamily        => 'RedHat'
        }
      end

      it 'should require vswitch::ovs' do
         is_expected.to contain_class('vswitch::ovs')
      end

      it 'create ovs bridge' do
        is_expected.to contain_augeas('Augeas_modify_ifcfg-ovsbridge').with(
          'name'    => 'vsm-br',
          'context' => '/files/etc/sysconfig/network-scripts/ifcfg-vsm-br',
        )
      end

      it 'flap bridge' do
        is_expected.to contain_exec('Flap_n1kv_bridge').with(
          'command'  => '/sbin/ifdown vsm-br && /sbin/ifup vsm-br',
        ).that_requires('Augeas[Augeas_modify_ifcfg-ovsbridge]')
      end

      it 'create patch port on existing bridge' do
        is_expected.to contain_exec('Create_patch_port_on_existing_bridge').with(
          'command' => '/bin/ovs-vsctl --may-exist add-port br_ex br_ex-vsm-br -- set Interface br_ex-vsm-br type=patch options:peer=vsm-br-br_ex'
        ).that_requires('Exec[Flap_n1kv_bridge]')
      end

      it 'create patch port on vsm bridge' do
        is_expected.to contain_exec('Create_patch_port_on_vsm_bridge').with(
          'command' => '/bin/ovs-vsctl --may-exist add-port vsm-br vsm-br-br_ex -- set Interface vsm-br-br_ex type=patch options:peer=br_ex-vsm-br'
        ).that_requires('Exec[Flap_n1kv_bridge]')
      end

      it 'tag patch port' do
        is_expected.to contain_exec('Tag_patch_port').with(
          'command' => '/bin/ovs-vsctl set port br_ex-vsm-br tag=100'
        ).that_requires('Exec[Create_patch_port_on_existing_bridge]')
      end
    end
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'n1k vsm pkgprep_ovscfg'
  end

end

