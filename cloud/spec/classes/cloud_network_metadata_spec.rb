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
# Unit tests for cloud::network::metadata class
#
require 'spec_helper'

describe 'cloud::network::metadata' do

  shared_examples_for 'openstack network metadata' do

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
      { :debug                                => true,
        :enabled                              => true,
        :neutron_metadata_proxy_shared_secret => 'secrete',
        :auth_region                          => 'MyRegion',
        :ks_neutron_password                  => 'secrete',
        :nova_metadata_server                 => '10.0.0.1',
        :ks_keystone_admin_proto              => 'http',
        :ks_keystone_admin_port               => '35357',
        :ks_nova_internal_proto               => 'https',
        :ks_keystone_admin_host               => '10.0.0.1' }
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

    it 'configure neutron metadata' do
      is_expected.to contain_class('neutron::agents::metadata').with(
          :debug            => true,
          :enabled          => true,
          :shared_secret    => 'secrete',
          :metadata_ip      => '10.0.0.1',
          :auth_url         => 'http://10.0.0.1:35357/v2.0',
          :auth_password    => 'secrete',
          :auth_region      => 'MyRegion',
          :metadata_workers => '8'
      )
      is_expected.to contain_neutron_metadata_agent_config('DEFAULT/nova_metadata_protocol').with(:value => 'https')
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :processorcount => '8' }
    end

    it_configures 'openstack network metadata'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :processorcount => '8' }
    end

    it_configures 'openstack network metadata'
  end

end
