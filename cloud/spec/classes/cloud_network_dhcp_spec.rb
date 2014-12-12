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
# Unit tests for cloud::network::dhcp class
#
require 'spec_helper'

describe 'cloud::network::dhcp' do

  shared_examples_for 'openstack network dhcp' do

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
      { :veth_mtu => '1400',
        :debug    => true }
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

    it 'configure neutron dhcp' do
      is_expected.to contain_class('neutron::agents::dhcp').with(
          :debug                    => true,
          :dnsmasq_config_file      => '/etc/neutron/dnsmasq-neutron.conf',
          :enable_isolated_metadata => true
      )

      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_dns_servers').with_ensure('absent')

      is_expected.to contain_file('/etc/neutron/dnsmasq-neutron.conf').with(
        :mode => '0755',
        :owner => 'root',
        :group => 'root'
      )
      is_expected.to contain_file('/etc/neutron/dnsmasq-neutron.conf').with_content(/^dhcp-option-force=26,1400$/)
    end
  end

  shared_examples_for 'openstack network dhcp with custom nameserver' do

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
      { :veth_mtu           => '1400',
        :debug              => true,
        :dnsmasq_dns_servers => ['1.2.3.4'] }
    end

    it 'configure neutron dhcp' do
      is_expected.to contain_class('neutron::agents::dhcp').with(
          :debug => true
      )

      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_config_file').with_value('/etc/neutron/dnsmasq-neutron.conf')
      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/enable_isolated_metadata').with_value(true)
      is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_dns_servers').with_value('1.2.3.4')

      is_expected.to contain_file('/etc/neutron/dnsmasq-neutron.conf').with(
        :mode => '0755',
        :owner => 'root',
        :group => 'root'
      )
      is_expected.to contain_file('/etc/neutron/dnsmasq-neutron.conf').with_content(/^dhcp-option-force=26,1400$/)

    end

    context 'with more than one dns server' do
      before { params.merge!(:dnsmasq_dns_servers => ['1.2.3.4','4.3.2.1','2.2.2.2']) }
      it { is_expected.to contain_neutron_dhcp_agent_config('DEFAULT/dnsmasq_dns_servers').with_value('1.2.3.4,4.3.2.1,2.2.2.2') }
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure neutron-server firewall rules' do
        is_expected.to contain_firewall('100 allow dhcp in access').with(
          :port   => '67',
          :proto  => 'udp',
          :chain  => 'INPUT',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow dhcp out access').with(
          :port   => '68',
          :proto  => 'udp',
          :chain  => 'OUTPUT',
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
        is_expected.to contain_firewall('100 allow dhcp in access').with(
          :port   => '67',
          :proto  => 'udp',
          :chain  => 'INPUT',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow dhcp out access').with(
          :port   => '68',
          :proto  => 'udp',
          :chain  => 'OUTPUT',
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

    it_configures 'openstack network dhcp'
    it_configures 'openstack network dhcp with custom nameserver'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack network dhcp'
    it_configures 'openstack network dhcp with custom nameserver'
  end

end
