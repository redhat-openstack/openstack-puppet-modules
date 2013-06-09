# == Class: snmp::server
#
# This class handles installing the SNMP daemon.
#
# === Parameters:
#
# [*ro_community*]
#   Read-only (RO) community string.
#   Default: public
#
# [*rw_community*]
#   Read-write (RW) community string.
#   Default: private
#
# [*ro_network*]
#   Network that is allowed to RO query the daemon.
#   Default: 127.0.0.1
#
# [*rw_network*]
#   Network that is allowed to RW query the daemon.
#   Default: 127.0.0.1
#
# [*contact*]
#   Responsible person for the SNMP system.
#   Default: Unknown
#
# [*location*]
#   Location of the SNMP system.
#   Default: Unknown
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
# [*service_ensure*]
#   Ensure if service is running or stopped.
#   Default: running
#
# [*service_name*]
#   Name of SNMP service
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*service_enable*]
#   Start service at boot.
#   Default: true
#
# [*service_hasstatus*]
#   Service has status command.
#   Default: true
#
# [*service_hasrestart*]
#   Service has restart command.
#   Default: true
#
# === Actions:
#
# Installs the SNMP daemon package, service, and configuration.
#
# === Requires:
#
# Class['snmp']
#
# === Sample Usage:
#
#   class { 'snmp::server':
#     ro_community => 'public',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2012 Mike Arnold, unless otherwise noted.
#
class snmp::server (
  $ro_community       = $snmp::params::ro_community,
  $rw_community       = $snmp::params::rw_community,
  $ro_network         = $snmp::params::ro_network,
  $rw_network         = $snmp::params::rw_network,
  $contact            = $snmp::params::contact,
  $location           = $snmp::params::location,
  $views              = $snmp::params::views,
  $accesses           = $snmp::params::accesses,
  $ensure             = 'present',
  $autoupgrade        = false,
  $package_name       = $snmp::params::package_name,
  $service_ensure     = 'running',
  $service_name       = $snmp::params::service_name,
  $service_enable     = true,
  $service_hasstatus  = true,
  $service_hasrestart = true
) inherits snmp::params {
  include snmp

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
      } else {
        $package_ensure = 'present'
      }
      $file_ensure = 'present'
      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $file_ensure = 'absent'
      $service_ensure_real = 'stopped'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  file { 'snmpd.conf':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::service_config,
    content => template('snmp/snmpd.conf.erb'),
    require => Package['snmpd'],
    notify  => Service['snmpd'],
  }

  file { 'snmpd.sysconfig':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::sysconfig,
    source  => [
      "puppet:///modules/snmp/snmpd.sysconfig-${::fqdn}",
      "puppet:///modules/snmp/snmpd.sysconfig-${::osfamily}-${::lsbmajdistrelease}",
      'puppet:///modules/snmp/snmpd.sysconfig',
    ],
    require => Package['snmpd'],
    notify  => Service['snmpd'],
  }

  service { 'snmpd':
    ensure     => $service_ensure_real,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
    require    => [ Package['snmpd'], File['var-net-snmp'], ],
  }
}
