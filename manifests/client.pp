# == Class: snmpd::client
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
# [*package_name*]
#   Name of the package.
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# === Actions:
#
# Installs the SNMP client package and configuration.
#
# === Requires:
#
# Class['snmpd']
#
# === Sample Usage:
#
#   class { 'snmpd::client': }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class snmpd::client (
  $ensure       = 'present',
  $autoupgrade  = false,
  $package_name = $snmpd::params::client_package_name
) inherits snmpd::params {
  #include snmpd
  #TODO: do we want the client to install and enable the server?

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

  package { 'snmp-client':
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { 'snmp.conf':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmpd::params::client_config,
    source  => [
      "puppet:///modules/snmpd/snmp.conf-${::fqdn}",
      "puppet:///modules/snmpd/snmp.conf-${::osfamily}-${::lsbmajdistrelease}",
      'puppet:///modules/snmpd/snmp.conf',
    ],
    require => Package['snmpd'],
  }
}
