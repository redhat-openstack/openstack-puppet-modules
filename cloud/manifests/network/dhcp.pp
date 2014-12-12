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
# == Class:
#
# Network DHCP node
#
# === Parameters:
#
# [*veth_mtu*]
#   (optional) Enforce the default virtual interface MTU (option 26)
#   Defaults to 1500
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*dnsmasq_dns_servers*]
#   (optional) An array of DNS IP used to configure Virtual server resolver
#   Defaults to false
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::network::dhcp(
  $veth_mtu            = 1500,
  $debug               = true,
  $dnsmasq_dns_servers = false,
  $firewall_settings   = {},
) {

  include 'cloud::network'
  include 'cloud::network::vswitch'

  class { 'neutron::agents::dhcp':
    debug                    => $debug,
    dnsmasq_config_file      => '/etc/neutron/dnsmasq-neutron.conf',
    enable_isolated_metadata => true
  }

  if $dnsmasq_dns_servers {
    neutron_dhcp_agent_config { 'DEFAULT/dnsmasq_dns_servers':
      value => join($dnsmasq_dns_servers, ',')
    }
  } else {
    neutron_dhcp_agent_config { 'DEFAULT/dnsmasq_dns_servers':
      ensure => absent
    }
  }

  file { '/etc/neutron/dnsmasq-neutron.conf':
    content => template('cloud/network/dnsmasq-neutron.conf.erb'),
    owner   => 'root',
    mode    => '0755',
    group   => 'root',
    notify  => Service['neutron-dhcp-agent']
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow dhcp in access':
      port   => '67',
      proto  => 'udp',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow dhcp out access':
      port   => '68',
      proto  => 'udp',
      chain  => 'OUTPUT',
      extras => $firewall_settings,
    }
  }

}
