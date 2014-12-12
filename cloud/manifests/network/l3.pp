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
# Network L3 node
#
# === Parameters:
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*ext_provider_net*]
#   (optional) Manage L3 with another provider
#   Defaults to false
#
# [*external_int*]
#   (optional) The name of the external nic
#   Defaults to eth1
#
# [*manage_tso*]
#  (optional) Disable TSO on Neutron interfaces
#  Defaults to true
#
class cloud::network::l3(
  $external_int     = 'eth1',
  $ext_provider_net = false,
  $debug            = true,
  $manage_tso       = true,
) {

  include 'cloud::network'
  include 'cloud::network::vswitch'

  if ! $ext_provider_net {
    vs_bridge{'br-ex':
      external_ids => 'bridge-id=br-ex',
    } ->
    vs_port{$external_int:
      ensure => present,
      bridge => 'br-ex'
    }
    $external_network_bridge_real = 'br-ex'
  } else {
    $external_network_bridge_real = ''
  }

  class { 'neutron::agents::l3':
    debug                   => $debug,
    external_network_bridge => $external_network_bridge_real
  }

  class { 'neutron::agents::metering':
    debug => $debug,
  }

  # Disabling TSO/GSO/GRO
  if $manage_tso {
    if $::osfamily == 'Debian' {
      ensure_resource ('exec','enable-tso-script', {
        'command' => '/usr/sbin/update-rc.d disable-tso defaults',
        'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
        'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
      })
    } elsif $::osfamily == 'RedHat' {
      ensure_resource ('exec','enable-tso-script', {
        'command' => '/usr/sbin/chkconfig disable-tso on',
        'unless'  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
        'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
      })
    }
    ensure_resource ('exec','start-tso-script', {
      'command' => '/etc/init.d/disable-tso start',
      'unless'  => '/usr/bin/test -f /var/run/disable-tso.pid',
      'onlyif'  => '/usr/bin/test -f /etc/init.d/disable-tso'
    })
  }

}
