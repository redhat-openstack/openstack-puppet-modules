# == Define: pacemaker::stonith::fence_xvm
#
# Configures stonith to use fence_xvm
#
# === Parameters:
#
# [*debug*]
#   (optional) Specify (stdin) or increment (command line) debug level
#   Defaults to undef
#
# [*ip_family*]
#   (optional) IP Family ([auto], ipv4, ipv6)
#   Defaults to 'auto'
#
# [*multicast_address*]
#   (optional) Multicast address
#   Defaults to undef
#
# [*ipport*]
#   (optional) TCP, Multicast, or VMChannel IP port
#   Defaults to undef
#
# [*retrans*]
#   (optional) Multicast retransmit time (in 1/10sec)
#   Defaults to undef
#
# [*auth*]
#   (optional) Authentication (none, sha1, [sha256], sha512)
#   Defaults to undef
#
# [*hash*]
#   (optional) Packet hash strength (none, sha1, [sha256], sha512)
#   Defaults to undef
#
# [*key_file*]
#   (optional) Shared key file
#   Defaults to /etc/cluster/fence_xvm.key
#
# [*port*]
#   (optional) Virtual Machine (domain name) to fence
#   Defaults to undef
#
# [*use_uuid*]
#   (optional) Treat [domain] as UUID instead of domain name. This is provided
#   forcompatibility with older fence_xvmd installations.
#   Defaults to undef
#
# [*timeout*]
#   (optional) Fencing timeout (in seconds)
#   Defaults to undef
#
# [*delay*]
#   (optional) Fencing delay (in seconds)
#   Defaults to undef
#
# [*domain*]
#   (optional) DEPRECATED, for compatibility only, use port.  Virtual Machine
#   (domain name) to fence
#   Defaults to undef
#
# [*interval*]
#   (optional) Monitor interval
#   Defaults to 60s
#
# [*ensure*]
#   (optional) Whether to make sure resource is present or absent
#   Defaults to present
#
# [*pcmk_host_list*]
#   (optional) List of nodes
#   Defaults to undef
#
# [*manage_key_file*]
#   (optional) Whether to create the keyfile if not present
#   Defaults to false
#
# [*key_file_password*]
#   (optional) Password for the key_file
#   Defaults to 123456
#
# [*manage_fw*]
#   (optional) Whether to manage the firewall settings related to this fencing
#   type
#   Defaults to true
#
# [*tries*]
#   (optional) How many times to attempt creating or deleting this resource
#   Defaults to undef
#
# [*try_sleep*]
#   (optional) How long to wait between tries
#   Defaults to undef
#
# === Dependencies
#  None
#
# === Authors:
#  Jiri Stransky <jistr@redhat.com>
#  Crag Wolfe <cwolfe@redhat.com>
#  Jason Guiditta <jguiditt@redhat.com>
#
# === Copyright
#
# Copyright (C) 2016 Red Hat Inc.
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
define pacemaker::stonith::fence_xvm (
  $debug             = undef,
  $ip_family         = undef,
  $multicast_address = undef,
  $ipport            = undef,
  $retrans           = undef,
  $auth              = undef,
  $hash              = undef,
  $key_file          = '/etc/cluster/fence_xvm.key',
  $port              = undef,
  $use_uuid          = undef,
  $timeout           = undef,
  $delay             = undef,
  $domain            = undef,

  $interval          = '60s',
  $ensure            = present,
  $pcmk_host_list    = undef,

  $manage_key_file   = false,
  $key_file_password = '123456',
  $manage_fw         = true,

  $tries             = undef,
  $try_sleep         = undef,
) {
  $debug_chunk = $debug ? {
    undef   => '',
    default => "debug=\"${debug}\"",
  }
  $ip_family_chunk = $ip_family ? {
    undef   => '',
    default => "ip_family=\"${ip_family}\"",
  }
  $multicast_address_chunk = $multicast_address ? {
    undef   => '',
    default => "multicast_address=\"${multicast_address}\"",
  }
  $ipport_chunk = $ipport ? {
    undef   => '',
    default => "ipport=\"${ipport}\"",
  }
  $retrans_chunk = $retrans ? {
    undef   => '',
    default => "retrans=\"${retrans}\"",
  }
  $auth_chunk = $auth ? {
    undef   => '',
    default => "auth=\"${auth}\"",
  }
  $hash_chunk = $hash ? {
    undef   => '',
    default => "hash=\"${hash}\"",
  }
  $key_file_chunk = $key_file ? {
    undef   => '',
    default => "key_file=\"${key_file}\"",
  }
  $port_chunk = $port ? {
    undef   => '',
    default => "port=\"${port}\"",
  }
  $use_uuid_chunk = $use_uuid ? {
    undef   => '',
    default => "use_uuid=\"${use_uuid}\"",
  }
  $timeout_chunk = $timeout ? {
    undef   => '',
    default => "timeout=\"${timeout}\"",
  }
  $delay_chunk = $delay ? {
    undef   => '',
    default => "delay=\"${delay}\"",
  }
  $domain_chunk = $domain ? {
    undef   => '',
    default => "domain=\"${domain}\"",
  }

  $pcmk_host_value_chunk = $pcmk_host_list ? {
    undef   => '$(/usr/sbin/crm_node -n)',
    default => $pcmk_host_list,
  }

  # $title can be a mac address, remove the colons for pcmk resource name
  $safe_title = regsubst($title, ':', '', 'G')

  if($ensure == absent) {
    exec { "Delete stonith-fence_xvm-${safe_title}":
      command => "/usr/sbin/pcs stonith delete stonith-fence_xvm-${safe_title}",
      onlyif  => "/usr/sbin/pcs stonith show stonith-fence_xvm-${safe_title} > /dev/null 2>&1",
      require => Class['pacemaker::corosync'],
    }
  } else {
    if str2bool($manage_key_file) {
      file { $key_file:
        content => $key_file_password,
      }
    }
    if str2bool($manage_fw) {
      firewall { '003 fence_xvm':
        proto  => 'igmp',
        action => 'accept',
      }
      firewall { '003 fence_xvm ipv6':
        proto    => 'igmp',
        action   => 'accept',
        provider => 'ip6tables',
      }
      firewall { '004 fence_xvm':
        proto  => 'udp',
        dport  => '1229',
        action => 'accept',
      }
      firewall { '004 fence_xvm ipv6':
        proto    => 'udp',
        dport    => '1229',
        action   => 'accept',
        provider => 'ip6tables',
      }
      firewall { '005 fence_xvm':
        proto  => 'tcp',
        dport  => '1229',
        action => 'accept',
      }
      firewall { '005 fence_xvm ipv6':
        proto    => 'tcp',
        dport    => '1229',
        action   => 'accept',
        provider => 'ip6tables',
      }
    }

    package {
      'fence-virt': ensure => installed,
    } ->
    exec { "Create stonith-fence_xvm-${safe_title}":
      command   => "/usr/sbin/pcs stonith create stonith-fence_xvm-${safe_title} fence_xvm pcmk_host_list=\"${pcmk_host_value_chunk}\" ${debug_chunk} ${ip_family_chunk} ${multicast_address_chunk} ${ipport_chunk} ${retrans_chunk} ${auth_chunk} ${hash_chunk} ${key_file_chunk} ${port_chunk} ${use_uuid_chunk} ${timeout_chunk} ${delay_chunk} ${domain_chunk}  op monitor interval=${interval}",
      unless    => "/usr/sbin/pcs stonith show stonith-fence_xvm-${safe_title} > /dev/null 2>&1",
      tries     => $tries,
      try_sleep => $try_sleep,
      require   => Class['pacemaker::corosync'],
    } ~>
    exec { "Add non-local constraint for stonith-fence_xvm-${safe_title}":
      command     => "/usr/sbin/pcs constraint location stonith-fence_xvm-${safe_title} avoids ${pcmk_host_value_chunk}",
      tries       => $tries,
      try_sleep   => $try_sleep,
      refreshonly => true,
    }
  }
}
