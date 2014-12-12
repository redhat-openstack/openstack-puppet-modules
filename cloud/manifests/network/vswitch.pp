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
# Network vswitch class
#
# === Parameters:
#
# [*driver*]
#   (optional) Neutron vswitch driver
#   Supported values: 'ml2_ovs', 'ml2_lb', 'n1kv_vem'.
#   Note: 'n1kv_vem' currently works only on Red Hat systems.
#   Defaults to 'ml2_ovs'
#
# [*external_int*]
#   (optionnal) Network interface to bind the external provider network
#   Defaults to 'eth1'.
#
# [*external_bridge*]
#   (optionnal) OVS bridge used to bind external provider network
#   Defaults to 'br-pub'.
#
# [*manage_ext_network*]
#   (optionnal) Manage or not external network with provider network API
#   Defaults to false.
#
# [*tunnel_eth*]
#   (optional) Interface IP used to build the tunnels
#   Defaults to '127.0.0.1'
#
# [*tunnel_typeis]
#   (optional) List of types of tunnels to use when utilizing tunnels
#   Defaults to ['gre']
#
# [*provider_bridge_mappings*]
#   (optional) List of <physical_network>:<bridge>
#
# [*n1kv_vsm_ip*]
#   (required) N1KV VSM (Virtual Supervisor Module) VM's IP.
#   Defaults to 127.0.0.1
#
# [*n1kv_vsm_domainid*]
#   (required) N1KV VSM DomainID.
#   Defaults to 1000
#
# [*host_mgmt_intf*]
#   (required) Management Interface of node where VEM will be installed.
#   Defaults to eth1
#
# [*uplink_profile*]
#   (optional) Uplink Interfaces that will be managed by VEM. The uplink
#      port-profile that configures these interfaces should also be specified.
#   (format)
#    $uplink_profile = { 'eth1' => 'profile1',
#                        'eth2' => 'profile2'
#                       },
#   Defaults to empty
#
# [*vtep_config*]
#   (optional) Virtual tunnel interface configuration.
#              Eg:VxLAN tunnel end-points.
#   (format)
#   $vtep_config = { 'vtep1' => { 'profile' => 'virtprof1',
#                                 'ipmode'  => 'dhcp'
#                               },
#                    'vtep2' => { 'profile'   => 'virtprof2',
#                                 'ipmode'    => 'static',
#                                 'ipaddress' => '192.168.1.1',
#                                 'netmask'   => '255.255.255.0'
#                               }
#                  },
#   Defaults to empty
#
# [*node_type*]
#   (optional). Specify the type of node: 'compute' (or) 'network'.
#   Defaults to 'compute'
#
# All the above parameter values will be used in the config file: n1kv.conf
#
# [*vteps_in_same_subnet*]
#   (optional)
#   The VXLAN tunnel interfaces created on VEM can belong to same IP-subnet.
#   In such case, set this parameter to true. This results in below
#   'sysctl:ipv4' values to be modified.
#     rp_filter (reverse path filtering) set to 2(Loose).Default is 1(Strict)
#     arp_ignore (arp reply mode) set to 1:reply only if target ip matches
#                                that of incoming interface. Default is 0
#   Please refer Linux Documentation for detailed description
#   http://lxr.free-electrons.com/source/Documentation/networking/ip-sysctl.txt
#
#   If the tunnel interfaces are not in same subnet set this parameter to false.
#   Note that setting to false causes no change in the sysctl settings and does
#   not revert the changes made if it was originally set to true on a previous
#   catalog run.
#
#   Defaults to false
#
# [*n1kv_source*]
#   (optional)
#     n1kv_source ==> VEM package location. One of below
#       A)URL of yum repository that hosts VEM package.
#       B)VEM RPM/DPKG file name, If present locally in 'files' folder
#       C)If not specified, assumes that VEM image is available in
#         default enabled repositories.
#   Defaults to empty
#
# [*n1kv_version*]
#   (optional). Specify VEM package version to be installed.
#       Not applicable if 'n1kv_source' is a file. (Option-B above)
#   Defaults to 'present'
#
# [*tunnel_types*]
#   (optional) List of types of tunnels to use when utilizing tunnels.
#   Supported tunnel types are: vxlan.
#   Defaults to ['gre']
#
# [*n1kv_vsm_domain_id*]
#   (optional) N1000 KV Domain ID (does nothing?)
#   Defaults to 1000
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::vswitch(
  # common
  $driver                   = 'ml2_ovs',
  $manage_ext_network       = false,
  $external_int             = 'eth1',
  $external_bridge          = 'br-pub',
  $firewall_settings        = {},
  # common to ml2
  $tunnel_types             = ['gre'],
  $tunnel_eth               = '127.0.0.1',
  # ml2_ovs
  $provider_bridge_mappings = ['public:br-pub'],
  # n1kv_vem
  $n1kv_vsm_ip              = '127.0.0.1',
  $n1kv_vsm_domain_id       = 1000,
  $host_mgmt_intf           = 'eth1',
  $uplink_profile           = {},
  $vtep_config              = {},
  $node_type                = 'compute',
  $vteps_in_same_subnet     = false,
  $n1kv_source              = '',
  $n1kv_version             = 'present',
) {

  include 'cloud::network'

  case $driver {
    'ml2_ovs': {
      class { 'neutron::agents::ml2::ovs':
        enable_tunneling => true,
        l2_population    => true,
        polling_interval => '15',
        tunnel_types     => $tunnel_types,
        bridge_mappings  => $provider_bridge_mappings,
        local_ip         => $tunnel_eth
      }

      if $::osfamily == 'RedHat' {
        kmod::load { 'ip_gre': }
      }
    }

    'ml2_lb': {
      class { 'neutron::agents::ml2::linuxbridge':
        l2_population    => true,
        polling_interval => '15',
        tunnel_types     => $tunnel_types,
        local_ip         => $tunnel_eth
      }

      if $::osfamily == 'RedHat' {
        kmod::load { 'ip_gre': }
      }
    }

    'n1kv_vem': {
      # We don't check if we are on Red Hat system
      # (already done by puppet-neutron)
      class { 'neutron::agents::n1kv_vem':
        n1kv_vsm_ip          => $n1kv_vsm_ip,
        n1kv_vsm_domain_id   => $n1kv_vsm_domain_id,
        host_mgmt_intf       => $host_mgmt_intf,
        uplink_profile       => $uplink_profile,
        vtep_config          => $vtep_config,
        node_type            => $node_type,
        vteps_in_same_subnet => $vteps_in_same_subnet,
        n1kv_source          => $n1kv_source,
        n1kv_version         => $n1kv_version,
      }
      ensure_resource('package', 'nexus1000v', {
        ensure => present
      })
    }

    default: {
      err "${driver} driver is not supported."
    }
  }

  if $manage_ext_network {
    vs_port {$external_int:
      ensure => present,
      bridge => $external_bridge
    }
  }

  if $::cloud::manage_firewall {
    if ('gre' in $tunnel_types) {
      cloud::firewall::rule{ '100 allow gre access':
        port   => undef,
        proto  => 'gre',
        extras => $firewall_settings,
      }
    }
    if ('vxlan' in $tunnel_types) {
      cloud::firewall::rule{ '100 allow vxlan access':
        port   => '4789',
        proto  => 'udp',
        extras => $firewall_settings,
      }
    }
  }

}
