# == Class: snmp
#
# This class handles installing the SNMP client utilities.
#
# === Parameters:
#
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
#
# [*autoupgrade*]
#   Upgrade package automatically, if there is a newer version.
#   Default: false
#
# === Actions:
#
# Installs the SNMP client package and configuration.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'snmp': }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class snmp (
  $ensure      = $snmp::params::ensure,
  $autoupgrade = $snmp::params::safe_autoupgrade
) inherits snmp::params {
  # Validate our booleans
  validate_bool($autoupgrade)

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      $file_ensure = 'present'
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $file_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { 'snmpd':
    ensure => $package_ensure,
    name   => $snmp::params::package_name,
  }

  package { 'snmp-client':
    ensure => $package_ensure,
    name   => $snmp::params::client_package_name,
  }

  file { 'snmp.conf':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::client_config,
    source  => [
      "puppet:///modules/snmp/snmp.conf-${::fqdn}",
      "puppet:///modules/snmp/snmp.conf-${::osfamily}-${::lsbmajdistrelease}",
      'puppet:///modules/snmp/snmp.conf',
    ],
    require => Package['snmpd'],
  }

  file { 'var-net-snmp':
    ensure  => 'directory',
    mode    => $snmp::params::varnetsnmp_perms,
    owner   => $snmp::params::varnetsnmp_owner,
    group   => $snmp::params::varnetsnmp_group,
    path    => $snmp::params::var_net_snmp,
    require => Package['snmpd'],
  }
}
