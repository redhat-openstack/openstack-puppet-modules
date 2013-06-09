# == Class: snmp::params
#
# This class handles OS-specific configuration of the snmp module.
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


# These should not need to be changed.
  case $::operatingsystem {
    'RedHat', 'CentOS', 'Scientific', 'SLC', 'OracleLinux', 'OEL': {
      #TODO: Use $::lsbmajdistrelease or $majdistrelease?
      #$majdistrelease = regsubst($::operatingsystemrelease,'^(\d+)\.(\d+)','\1')

      $package_name        = 'net-snmp'
      $service_config      = '/etc/snmp/snmpd.conf'
      $service_name        = 'snmpd'
      if $::lsbmajdistrelease <= '5' {
        $sysconfig         = '/etc/sysconfig/snmpd.options'
        $var_net_snmp      = '/var/net-snmp'
        $varnetsnmp_perms  = '0700'
      } else {
        $sysconfig         = '/etc/sysconfig/snmpd'
        $var_net_snmp      = '/var/lib/net-snmp'
        $varnetsnmp_perms  = '0755'
      }

      $client_package_name = 'net-snmp-utils'
      $client_config       = '/etc/snmp/snmp.conf'

      $trap_service_config = '/etc/snmp/snmptrapd.conf'
      $trap_service_name   = 'snmptrapd'
      if $::lsbmajdistrelease <= '5' {
        $trap_sysconfig    = '/etc/sysconfig/snmptrapd.options'
      } else {
        $trap_sysconfig    = '/etc/sysconfig/snmptrapd'
      }
    }
    'Fedora': {
      fail("Module snmp is not yet supported on ${::operatingsystem}")
    }
    default: {
      fail("Module snmp is not supported on ${::operatingsystem}")
    }
  }
}
