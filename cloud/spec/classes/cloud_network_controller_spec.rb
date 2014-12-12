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
# Unit tests for cloud::network::controller class
#
require 'spec_helper'

describe 'cloud::network::controller' do

  shared_examples_for 'openstack network controller' do

    let :pre_condition do
      "class { 'cloud::network':
        rabbit_hosts             => ['10.0.0.1'],
        rabbit_password          => 'secrete',
        api_eth                  => '10.0.0.1',
        verbose                  => true,
        debug                    => true,
        use_syslog               => true,
        dhcp_lease_duration      => '10',
        log_facility             => 'LOG_LOCAL0' }"
    end

    let :params do
      { :neutron_db_host          => '10.0.0.1',
        :neutron_db_user          => 'neutron',
        :neutron_db_password      => 'secrete',
        :ks_neutron_password      => 'secrete',
        :ks_keystone_admin_host   => '10.0.0.1',
        :ks_keystone_admin_proto  => 'https',
        :ks_keystone_public_port  => '5000',
        :nova_url                 => 'http://127.0.0.1:8774/v2',
        :nova_admin_auth_url      => 'http://127.0.0.1:5000/v2.0',
        :nova_admin_username      => 'nova',
        :nova_admin_tenant_name   => 'services',
        :nova_admin_password      => 'novapassword',
        :nova_region_name         => 'RegionOne',
        :manage_ext_network       => false,
        :api_eth                  => '10.0.0.1' }
    end

    it 'configure neutron common' do
      is_expected.to contain_class('neutron').with(
          :allow_overlapping_ips   => true,
          :dhcp_agents_per_network => '2',
          :verbose                 => true,
          :debug                   => true,
          :log_facility            => 'LOG_LOCAL0',
          :use_syslog              => true,
          :rabbit_user             => 'neutron',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :bind_host               => '10.0.0.1',
          :core_plugin             => 'neutron.plugins.ml2.plugin.Ml2Plugin',
          :service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
          :log_dir                 => false,
          :dhcp_lease_duration     => '10',
          :report_interval         => '30'
      )
      is_expected.to contain_class('neutron::plugins::ml2').with(
          :type_drivers           => ['gre', 'vlan', 'flat'],
          :tenant_network_types   => ['gre'],
          :mechanism_drivers      => ['linuxbridge','openvswitch','l2population'],
          :tunnel_id_ranges       => ['1:10000'],
          :vni_ranges             => ['1:10000'],
          :network_vlan_ranges    => ['physnet1:1000:2999'],
          :flat_networks          => ['public'],
          :enable_security_group  => true
      )
    end

    it 'configure neutron server' do
      is_expected.to contain_class('neutron::server').with(
          :auth_password       => 'secrete',
          :auth_host           => '10.0.0.1',
          :auth_port           => '5000',
          :auth_protocol       => 'https',
          :database_connection => 'mysql://neutron:secrete@10.0.0.1/neutron?charset=utf8',
          :api_workers         => '2',
          :agent_down_time     => '60'
        )
    end

    it 'configure neutron server notifications to nova' do
      is_expected.to contain_class('neutron::server::notifications').with(
        :nova_url                => 'http://127.0.0.1:8774/v2',
        :nova_admin_auth_url     => 'http://127.0.0.1:5000/v2.0',
        :nova_admin_username     => 'nova',
        :nova_admin_tenant_name  => 'services',
        :nova_admin_password     => 'novapassword',
        :nova_region_name        => 'RegionOne'
      )
    end
    it 'checks if Neutron DB is populated' do
      is_expected.to contain_exec('neutron_db_sync').with(
        :command => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
        :path    => '/usr/bin',
        :user    => 'neutron',
        :unless  => '/usr/bin/mysql neutron -h 10.0.0.1 -u neutron -psecrete -e "show tables" | /bin/grep Tables',
        :require => 'Neutron_config[DEFAULT/service_plugins]',
        :notify  => 'Service[neutron-server]'
      )
    end

    it 'should not configure provider external network' do
      is_expected.not_to contain__neutron_network('public')
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure neutron-server firewall rules' do
        is_expected.to contain_firewall('100 allow neutron-server access').with(
          :port   => '9696',
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
      it 'configure neutrons-server firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow neutron-server access').with(
          :port   => '9696',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

    context 'with custom ml2 parameters' do
      before :each do
        params.merge!(
          :tenant_network_types => ['vxlan'],
          :type_drivers         => ['gre', 'vlan', 'flat', 'vxlan'],
          :tunnel_id_ranges     => ['100:300'],
          :vni_ranges           => ['42:51','53:69'],
        )
      end
      it 'contains correct parameters' do
        is_expected.to contain_class('neutron::plugins::ml2').with(
          :type_drivers           => ['gre', 'vlan', 'flat', 'vxlan'],
          :tenant_network_types   => ['vxlan'],
          :mechanism_drivers      => ['linuxbridge', 'openvswitch','l2population'],
          :tunnel_id_ranges       => ['100:300'],
          :vni_ranges             => ['42:51','53:69'],
          :network_vlan_ranges    => ['physnet1:1000:2999'],
          :flat_networks          => ['public'],
          :enable_security_group  => true
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily      => 'Debian',
        :processorcount => '2' }
    end

    it_configures 'openstack network controller'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => '2' }
    end

    it_configures 'openstack network controller'
  end

end
