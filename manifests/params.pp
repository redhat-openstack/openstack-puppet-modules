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
# TODO
  $ro_community = 'public'
  $rw_community = 'private'
  $ro_network   = '127.0.0.1'
  $rw_network   = '127.0.0.1'
  $contact      = 'Unknown'
  $location     = 'Unknown'
  $views        = [
    'view    systemview    included   .1.3.6.1.2.1.1',
    'view    systemview    included   .1.3.6.1.2.1.25.1.1',
  ]
  $accesses     = [
    'access  notConfigGroup ""      any       noauth    exact  systemview none none',
  ]

### The following parameters should not need to be changed.

  $ensure = $::snmp_ensure ? {
    undef => 'present',
    default => $::snmp_ensure,
  }

  $service_ensure = $::snmp_service_ensure ? {
    undef => 'running',
    default => $::snmp_service_ensure,
  }

  # Since the top scope variable could be a string (if from an ENC), we might
  # need to convert it to a boolean.
  $autoupgrade = $::snmp_autoupgrade ? {
    undef => false,
    default => $::snmp_autoupgrade,
  }
  if is_string($autoupgrade) {
    $safe_autoupgrade = str2bool($autoupgrade)
  } else {
    $safe_autoupgrade = $autoupgrade
  }

  $service_enable = $::snmp_service_enable ? {
    undef => true,
    default => $::snmp_service_enable,
  }
  if is_string($service_enable) {
    $safe_service_enable = str2bool($service_enable)
  } else {
    $safe_service_enable = $service_enable
  }

  case $::osfamily {
    'RedHat': {
      #TODO: Use $::lsbmajdistrelease or $majdistrelease?
      #$majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')

      $package_name        = 'net-snmp'
      $service_config      = '/etc/snmp/snmpd.conf'
      $service_config_perms= '0644'
      $service_name        = 'snmpd'
      if ($::lsbmajdistrelease <= '5') and ($::operatingsystem != 'Fedora') {
        $sysconfig         = '/etc/sysconfig/snmpd.options'
        $var_net_snmp      = '/var/net-snmp'
        $varnetsnmp_perms  = '0700'
      } else {
        $sysconfig         = '/etc/sysconfig/snmpd'
        $var_net_snmp      = '/var/lib/net-snmp'
        $varnetsnmp_perms  = '0755'
      }
      $varnetsnmp_owner    = 'root'
      $varnetsnmp_group    = 'root'

      $client_package_name = 'net-snmp-utils'
      $client_config       = '/etc/snmp/snmp.conf'

      $trap_service_config = '/etc/snmp/snmptrapd.conf'
      $trap_service_name   = 'snmptrapd'
      if ($::lsbmajdistrelease <= '5') and ($::operatingsystem != 'Fedora') {
        $trap_sysconfig    = '/etc/sysconfig/snmptrapd.options'
      } else {
        $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
      }
    }
    'Debian': {
      $package_name        = 'snmpd'
      $service_config      = '/etc/snmp/snmpd.conf'
      $service_config_perms= '0600'
      $service_name        = 'snmpd'
      $sysconfig           = '/etc/default/snmp'
      $var_net_snmp        = '/var/lib/snmp'
      $varnetsnmp_perms    = '0755'
      $varnetsnmp_owner    = 'snmp'
      $varnetsnmp_group    = 'snmp'

      $client_package_name = 'snmp'
      $client_config       = '/etc/snmp/snmp.conf'

      $trap_service_config = '/etc/snmp/snmptrapd.conf'
      $trap_service_name   = 'snmptrapd'
    }
    default: {
      fail("Module ${::module} is not supported on ${::operatingsystem}")
    }
  }
}
