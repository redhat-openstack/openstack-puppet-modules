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
# Unit tests for cloud::network::l3 class
#
require 'spec_helper'

describe 'cloud::network::l3' do

  shared_examples_for 'openstack network l3' do

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
      { :debug        => true,
        :external_int => 'eth1' }
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

    it 'configure neutron l3' do
      is_expected.to contain_class('neutron::agents::l3').with(
          :debug                   => true,
          :external_network_bridge => 'br-ex'
      )
    end
    it 'configure br-ex bridge' do
      is_expected.not_to contain__vs_bridge('br-ex')
    end

    it 'configure neutron metering agent' do
      is_expected.to contain_class('neutron::agents::metering').with(
          :debug => true
      )
    end

    context 'without TSO/GSO/GRO on Red Hat systems' do
      before :each do
        facts.merge!( :osfamily => 'RedHat')
      end

      it 'ensure TSO script is enabled at boot' do
        is_expected.to contain_exec('enable-tso-script').with(
          :command => '/usr/sbin/chkconfig disable-tso on',
          :unless  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
      it 'start TSO script' do
        is_expected.to contain_exec('start-tso-script').with(
          :command => '/etc/init.d/disable-tso start',
          :unless  => '/usr/bin/test -f /var/run/disable-tso.pid',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
    end

    context 'without TSO/GSO/GRO on Debian systems' do
      before :each do
        facts.merge!( :osfamily => 'Debian')
      end

      it 'ensure TSO script is enabled at boot' do
        is_expected.to contain_exec('enable-tso-script').with(
          :command => '/usr/sbin/update-rc.d disable-tso defaults',
          :unless  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
      it 'start TSO script' do
        is_expected.to contain_exec('start-tso-script').with(
          :command => '/etc/init.d/disable-tso start',
          :unless  => '/usr/bin/test -f /var/run/disable-tso.pid',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
    end

    context 'when not managing TSO/GSO/GRO' do
      before :each do
        params.merge!( :manage_tso => false)
      end
      it 'ensure TSO script is not enabled at boot' do
        is_expected.not_to contain_exec('enable-tso-script')
      end
      it 'do not start TSO script' do
        is_expected.not_to contain_exec('start-tso-script')
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    it_configures 'openstack network l3'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    it_configures 'openstack network l3'
  end

end
