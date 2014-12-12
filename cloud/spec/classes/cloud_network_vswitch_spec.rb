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
# Unit tests for cloud::network::vswitch class
#
require 'spec_helper'

describe 'cloud::network::vswitch' do

  shared_examples_for 'openstack network vswitch' do

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
      {
        :tunnel_eth => '10.0.1.1'
      }
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
    end

    context 'when running ML2 plugin with OVS driver' do
      it 'configure neutron vswitch' do
        is_expected.to contain_class('neutron::agents::ml2::ovs').with(
            :enable_tunneling => true,
            :tunnel_types     => ['gre'],
            :bridge_mappings  => ['public:br-pub'],
            :local_ip         => '10.0.1.1'
        )
      end
    end

    context 'when running Cisco N1KV plugin with VEM driver' do
      before do
       facts.merge!( :osfamily => 'RedHat' )
       params.merge!(
         :driver      => 'n1kv_vem',
         :n1kv_vsm_ip => '10.0.1.1'
       )
      end
      it 'configure neutron n1kv agent' do
        should contain_class('neutron::agents::n1kv_vem').with(
          :n1kv_vsm_ip        => '10.0.1.1',
          :n1kv_vsm_domain_id => '1000',
          :host_mgmt_intf     => 'eth1',
          :node_type          => 'compute'
        )
      end
      it 'ensure cisco VEM package is present' do
        should contain_package('nexus1000v').with(
          :ensure => 'present'
        )
      end
    end

    context 'when using provider external network' do
      before do
       params.merge!(
         :manage_ext_network => true,
       )
      end

      it 'configure br-pub bridge' do
        is_expected.to contain_vs_bridge('br-pub')
      end
      it 'configure eth1 in br-pub' do
        is_expected.to contain_vs_port('eth1').with(
          :ensure => 'present',
          :bridge => 'br-pub'
        )
      end

    end

    context 'with unsupported Neutron driver' do
      before :each do
        params.merge!(:driver => 'Something')
      end
      it { should compile.and_raise_error(/Something plugin is not supported./) }
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure gre firewall rules' do
        is_expected.to contain_firewall('100 allow gre access').with(
          :port   => nil,
          :proto  => 'gre',
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
      it 'configure gre firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow gre access').with(
          :port   => nil,
          :proto  => 'gre',
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

    it_configures 'openstack network vswitch'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack network vswitch'
  end

end
