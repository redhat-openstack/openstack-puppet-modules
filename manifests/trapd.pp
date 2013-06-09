# == Class: snmp::trapd
#
# This class handles installing the SNMP trap daemon.
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
# [*ensure*]
#   Ensure if present or absent.
#   Default: present
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
# Installs the SNMP trap daemon service and configuration.
#
# === Requires:
#
# Class['snmp']
#
# === Sample Usage:
#
#   class { 'snmp::trapd':
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
class snmp::trapd (
  $ro_community       = $snmp::params::ro_community,
  $rw_community       = $snmp::params::rw_community,
  $trap_handlers      = [],
  $ensure             = 'present',
  $service_ensure     = 'running',
  $service_name       = $snmp::params::trap_service_name,
  $service_enable     = true,
  $service_hasstatus  = true,
  $service_hasrestart = true
) inherits snmp::params {
  include snmp

  case $ensure {
    /(present)/: {
      $file_ensure = 'present'
      if $service_ensure in [ running, stopped ] {
        $service_ensure_real = $service_ensure
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
    }
    /(absent)/: {
      $file_ensure = 'absent'
      $service_ensure_real = 'stopped'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  file { 'snmptrapd.conf':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::trap_service_config,
    content => template('snmp/snmptrapd.conf.erb'),
    require => Package['snmpd'],
    notify  => Service['snmptrapd'],
  }

  file { 'snmptrapd.sysconfig':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::trap_sysconfig,
    source  => [
      "puppet:///modules/snmp/snmptrapd.sysconfig-${::fqdn}",
      "puppet:///modules/snmp/snmptrapd.sysconfig-${::osfamily}-${::lsbmajdistrelease}",
      'puppet:///modules/snmp/snmptrapd.sysconfig',
    ],
    require => Package['snmpd'],
    notify  => Service['snmptrapd'],
  }

  service { 'snmptrapd':
    ensure     => $service_ensure_real,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
    require    => [ Package['snmpd'], File['var-net-snmp'], ],
  }
}
