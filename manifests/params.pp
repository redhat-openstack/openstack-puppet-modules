# == Class: snmp::params
#
# This class handles OS-specific configuration of the snmp module.  It
# looks for variables in top scope (probably from an ENC such as Dashboard).  If
# the variable doesn't exist in top scope, it falls back to a hard coded default
# value.
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class snmp::params {
  # If we have a top scope variable defined, use it, otherwise fall back to a
  # hardcoded value.
  $agentaddress = $::snmp_agentaddress ? {
    undef   => [ 'udp:127.0.0.1:161' ],
    default => $::snmp_agentaddress,
  }

  $snmptrapdaddr = $::snmp_snmptrapdaddr ? {
    undef   => [ 'udp:127.0.0.1:162' ],
    default => $::snmp_snmptrapdaddr,
  }

  $ro_community = $::snmp_ro_community ? {
    undef   => 'public',
    default => $::snmp_ro_community,
  }

  $rw_community = $::snmp_rw_community ? {
    undef   => undef,
    default => $::snmp_rw_community,
  }

  $ro_network = $::snmp_ro_network ? {
    undef   => '127.0.0.1',
    default => $::snmp_ro_network,
  }

  $rw_network = $::snmp_rw_network ? {
    undef   => '127.0.0.1',
    default => $::snmp_rw_network,
  }

  $contact = $::snmp_contact ? {
    undef   => 'Unknown',
    default => $::snmp_contact,
  }

  $location = $::snmp_location ? {
    undef   => 'Unknown',
    default => $::snmp_location,
  }

  $services = $::snmp_services ? {
    undef   => 72,
    default => $::snmp_services,
  }

  $views = $::snmp_views ? {
    undef   => [
      'systemview    included   .1.3.6.1.2.1.1',
      'systemview    included   .1.3.6.1.2.1.25.1.1',
    ],
    default => $::snmp_views,
  }

  $accesses = $::snmp_accesses ? {
    undef   => [
      'notConfigGroup ""      any       noauth    exact  systemview none  none',
    ],
    default => $::snmp_accesses,
  }

  $dlmod = $::snmp_dlmod ? {
    undef   => [],
    default => $::snmp_dlmod,
  }

  $disable_authorization = $::snmp_disable_authorization ? {
    undef   => 'no',
    default => $::snmp_disable_authorization,
  }

  $do_not_log_traps = $::snmp_do_not_log_traps ? {
    undef   => 'no',
    default => $::snmp_do_not_log_traps,
  }

  $trap_handlers = $::snmp_trap_handlers ? {
    undef   => [],
    default => $::snmp_trap_handlers,
  }

  $trap_forwards = $::snmp_trap_forwards ? {
    undef   => [],
    default => $::snmp_trap_forwards,
  }

  $snmp_config = $::snmp_snmp_config ? {
    undef   => [],
    default => $::snmp_snmp_config,
  }

  $snmpd_config = $::snmp_snmpd_config ? {
    undef   => [],
    default => $::snmp_snmpd_config,
  }

  $snmptrapd_config = $::snmp_snmptrapd_config ? {
    undef   => [],
    default => $::snmp_snmptrapd_config,
  }

### The following parameters should not need to be changed.

  $ensure = $::snmp_ensure ? {
    undef   => 'present',
    default => $::snmp_ensure,
  }

  $service_ensure = $::snmp_service_ensure ? {
    undef   => 'running',
    default => $::snmp_service_ensure,
  }

  $trap_service_ensure = $::snmp_trap_service_ensure ? {
    undef   => 'stopped',
    default => $::snmp_trap_service_ensure,
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $autoupgrade = $::snmp_autoupgrade ? {
    undef   => false,
    default => $::snmp_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $install_client = $::snmp_install_client ? {
    undef   => false,
    default => $::snmp_install_client,
  }
  if is_string($install_client) {
    $safe_install_client = str2bool($install_client)
  } else {
    $safe_install_client = $install_client
  }

  $service_enable = $::snmp_service_enable ? {
    undef   => true,
    default => $::snmp_service_enable,
  }
  if is_string($service_enable) {
    $safe_service_enable = str2bool($service_enable)
  } else {
    $safe_service_enable = $service_enable
  }

  $service_hasstatus = $::snmp_service_hasstatus ? {
    undef   => true,
    default => $::snmp_service_hasstatus,
  }
  if is_string($service_hasstatus) {
    $safe_service_hasstatus = str2bool($service_hasstatus)
  } else {
    $safe_service_hasstatus = $service_hasstatus
  }

  $service_hasrestart = $::snmp_service_hasrestart ? {
    undef   => true,
    default => $::snmp_service_hasrestart,
  }
  if is_string($service_hasrestart) {
    $safe_service_hasrestart = str2bool($service_hasrestart)
  } else {
    $safe_service_hasrestart = $service_hasrestart
  }

  $trap_service_enable = $::snmp_trap_service_enable ? {
    undef   => false,
    default => $::snmp_trap_service_enable,
  }
  if is_string($trap_service_enable) {
    $safe_trap_service_enable = str2bool($trap_service_enable)
  } else {
    $safe_trap_service_enable = $trap_service_enable
  }

  $trap_service_hasstatus = $::snmp_trap_service_hasstatus ? {
    undef   => true,
    default => $::snmp_trap_service_hasstatus,
  }
  if is_string($trap_service_hasstatus) {
    $safe_trap_service_hasstatus = str2bool($trap_service_hasstatus)
  } else {
    $safe_trap_service_hasstatus = $trap_service_hasstatus
  }

  $trap_service_hasrestart = $::snmp_trap_service_hasrestart ? {
    undef   => true,
    default => $::snmp_trap_service_hasrestart,
  }
  if is_string($trap_service_hasrestart) {
    $safe_trap_service_hasrestart = str2bool($trap_service_hasrestart)
  } else {
    $safe_trap_service_hasrestart = $trap_service_hasrestart
  }

  case $::osfamily {
    'RedHat': {
      $majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')
      case $::operatingsystem {
        'Fedora': {
          $snmpd_options     = '-LS0-6d'
          $snmptrapd_options = '-Lsd'
          $sysconfig         = '/etc/sysconfig/snmpd'
          $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
          $var_net_snmp      = '/var/lib/net-snmp'
          $varnetsnmp_perms  = '0755'
        }
        default: {
          if $majdistrelease <= '5' {
            $snmpd_options    = '-Lsd -Lf /dev/null -p /var/run/snmpd.pid -a'
            $sysconfig        = '/etc/sysconfig/snmpd.options'
            $trap_sysconfig   = '/etc/sysconfig/snmptrapd.options'
            $var_net_snmp     = '/var/net-snmp'
            $varnetsnmp_perms = '0700'
          } else {
            $snmpd_options    = '-LS0-6d -Lf /dev/null -p /var/run/snmpd.pid'
            $sysconfig        = '/etc/sysconfig/snmpd'
            $trap_sysconfig   = '/etc/sysconfig/snmptrapd'
            $var_net_snmp     = '/var/lib/net-snmp'
            $varnetsnmp_perms = '0755'
          }
          $snmptrapd_options = '-Lsd -p /var/run/snmptrapd.pid'
        }
      }
      $package_name         = 'net-snmp'
      $service_config       = '/etc/snmp/snmpd.conf'
      $service_config_perms = '0644'
      $service_name         = 'snmpd'
      $varnetsnmp_owner     = 'root'
      $varnetsnmp_group     = 'root'

      $client_package_name  = 'net-snmp-utils'
      $client_config        = '/etc/snmp/snmp.conf'

      $trap_service_config  = '/etc/snmp/snmptrapd.conf'
      $trap_service_name    = 'snmptrapd'
    }
    'Debian': {
      $package_name         = 'snmpd'
      $service_config       = '/etc/snmp/snmpd.conf'
      $service_config_perms = '0600'
      $service_name         = 'snmpd'
      $snmpd_options        = '-Lsd -Lf /dev/null -u snmp -g snmp -I -smux -p /var/run/snmpd.pid'
      $sysconfig            = '/etc/default/snmpd'
      $var_net_snmp         = '/var/lib/snmp'
      $varnetsnmp_perms     = '0755'
      $varnetsnmp_owner     = 'snmp'
      $varnetsnmp_group     = 'snmp'

      $client_package_name  = 'snmp'
      $client_config        = '/etc/snmp/snmp.conf'

      $trap_service_config  = '/etc/snmp/snmptrapd.conf'
      $snmptrapd_options    = '-Lsd -p /var/run/snmptrapd.pid'
    }
    'Suse': {
      $package_name         = 'net-snmp'
      $service_config       = '/etc/snmp/snmpd.conf'
      $service_config_perms = '0600'
      $service_name         = 'snmpd'
      $snmpd_options        = 'd'
      $sysconfig            = '/etc/sysconfig/net-snmp'
      $var_net_snmp         = '/var/lib/net-snmp'
      $varnetsnmp_perms     = '0755'
      $varnetsnmp_owner     = 'root'
      $varnetsnmp_group     = 'root'

      $client_package_name  = 'net-snmp'
      $client_config        = '/etc/snmp/snmp.conf'

      $trap_service_config  = '/etc/snmp/snmptrapd.conf'
      $trap_service_name    = 'snmptrapd'
      $snmptrapd_options    = ''
    }
    default: {
      fail("Module ${::module} is not supported on ${::operatingsystem}")
    }
  }
}
