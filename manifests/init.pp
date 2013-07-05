# == Class: snmp
#
# This class handles installing the Net-SNMP server and trap server.
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
# [*views*]
#   An array of views that are available to query.
#   Default: 'view systemview included .1.3.6.1.2.1.1' and
#            'view systemview included .1.3.6.1.2.1.25.1.1'
#
# [*accesses*]
#   An array of access controls that are available to query.
#   Default: 'access notConfigGroup "" any noauth exact systemview none none'
#
# [*trap_handlers*]
#   An array of programs to invoke on receipt of traps.
#   See http://www.net-snmp.org/docs/man/snmptrapd.conf.html section
#   NOTIFICATION PROCESSING.
#   Default: none
#
# [*install_client*]
#   Whether to install the Net-SNMP client package.
#   Default: false
#
# [*snmp_config*]
#   Array of lines to add to the client's global snmp.conf file.
#   See http://www.net-snmp.org/docs/man/snmp.conf.html for all options.
#   Default: none
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
# [*snmpd_options*]
#   Commandline options passed to snmpd via init script.
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
# [*snmptrapd_options*]
#   Commandline options passed to snmptrapd via init script.
#   Default: auto-set, platform specific
#
# [*trap_service_ensure*]
#   Ensure if service is running or stopped.
#   Default: stopped
#
# [*trap_service_name*]
#   Name of SNMP service
#   Only set this if your platform is not supported or you know what you are
#   doing.
#   Default: auto-set, platform specific
#
# [*trap_service_enable*]
#   Start service at boot.
#   Default: true
#
# [*trap_service_hasstatus*]
#   Service has status command.
#   Default: true
#
# [*trap_service_hasrestart*]
#   Service has restart command.
#   Default: true
#
# === Actions:
#
# Installs the Net-SNMP daemon package, service, and configuration.
# Installs the Net-SNMP trap daemon service and configuration.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   # Configure and run the snmp daemon and install the client:
#   class { 'snmp':
#     ro_community   => 'public',
#     install_client => true,
#   }
#
#   # Only configure and run the snmptrap daemon:
#   class { 'snmp':
#     ro_community        => 'SeCrEt',
#     service_ensure      => 'stopped',
#     trap_service_ensure => 'running',
#     trap_handlers       => [
#       'traphandle default /usr/bin/perl /usr/bin/traptoemail me@somewhere.com',
#       'traphandle TRAP-TEST-MIB::demo-trap /home/user/traptest.sh demo-trap',
#     ],
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
class snmp (
  $ro_community            = $snmp::params::ro_community,
  $rw_community            = $snmp::params::rw_community,
  $ro_network              = $snmp::params::ro_network,
  $rw_network              = $snmp::params::rw_network,
  $contact                 = $snmp::params::contact,
  $location                = $snmp::params::location,
  $views                   = $snmp::params::views,
  $accesses                = $snmp::params::accesses,
  $trap_handlers           = $snmp::params::trap_handlers,
  $install_client          = $snmp::params::install_client,
  $snmp_config             = $snmp::params::snmp_config,
  $ensure                  = $snmp::params::ensure,
  $autoupgrade             = $snmp::params::safe_autoupgrade,
  $package_name            = $snmp::params::package_name,
  $snmpd_options           = $snmp::params::snmpd_options,
  $service_ensure          = $snmp::params::service_ensure,
  $service_name            = $snmp::params::service_name,
  $service_enable          = $snmp::params::service_enable,
  $service_hasstatus       = $snmp::params::service_hasstatus,
  $service_hasrestart      = $snmp::params::service_hasrestart,
  $snmptrapd_options       = $snmp::params::snmptrapd_options,
  $trap_service_ensure     = $snmp::params::trap_service_ensure,
  $trap_service_name       = $snmp::params::trap_service_name,
  $trap_service_enable     = $snmp::params::trap_service_enable,
  $trap_service_hasstatus  = $snmp::params::trap_service_hasstatus,
  $trap_service_hasrestart = $snmp::params::trap_service_hasrestart
) inherits snmp::params {
  # Validate our booleans
  validate_bool($install_client)
  validate_bool($autoupgrade)
  validate_bool($service_enable)
  validate_bool($service_hasstatus)
  validate_bool($service_hasrestart)

  # Validate our arrays
  validate_array($trap_handlers)
  validate_array($snmp_config)
  validate_array($views)
  validate_array($accesses)

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
        $service_enable_real = $service_enable
      } else {
        fail('service_ensure parameter must be running or stopped')
      }
      if $trap_service_ensure in [ running, stopped ] {
        $trap_service_ensure_real = $trap_service_ensure
        $trap_service_enable_real = $trap_service_enable
      } else {
        fail('trap_service_ensure parameter must be running or stopped')
      }
    }
    /(absent)/: {
      $package_ensure = 'absent'
      $file_ensure = 'absent'
      $service_ensure_real = 'stopped'
      $service_enable_real = false
      $trap_service_ensure_real = 'stopped'
      $trap_service_enable_real = false
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  if $service_ensure_real == 'running' {
    $snmpdrun = 'yes'
  } else {
    $snmpdrun = 'no'
  }
  if $trap_service_ensure_real == 'running' {
    $trapdrun = 'yes'
  } else {
    $trapdrun = 'no'
  }

  if $::osfamily != 'Debian' {
    $snmptrapd_conf_notify = Service['snmptrapd']
  } else {
    $snmptrapd_conf_notify = Service['snmpd']
  }

  if $install_client {
    class { 'snmp::client':
      ensure        => $ensure,
      autoupgrade   => $autoupgrade,
      snmp_config   => $snmp_config,
    }
  }

  package { 'snmpd':
    ensure => $package_ensure,
    name   => $package_name,
  }

  file { 'var-net-snmp':
    ensure  => 'directory',
    mode    => $snmp::params::varnetsnmp_perms,
    owner   => $snmp::params::varnetsnmp_owner,
    group   => $snmp::params::varnetsnmp_group,
    path    => $snmp::params::var_net_snmp,
    require => Package['snmpd'],
  }

  file { 'snmpd.conf':
    ensure  => $file_ensure,
    mode    => $snmp::params::service_config_perms,
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
    content => template("snmp/snmpd.sysconfig-${::osfamily}.erb"),
    require => Package['snmpd'],
    notify  => Service['snmpd'],
  }

  file { 'snmptrapd.conf':
    ensure  => $file_ensure,
    mode    => $snmp::params::service_config_perms,
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::trap_service_config,
    content => template('snmp/snmptrapd.conf.erb'),
    require => Package['snmpd'],
    notify  => $snmptrapd_conf_notify,
  }

  if $::osfamily != 'Debian' {
    file { 'snmptrapd.sysconfig':
      ensure  => $file_ensure,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      path    => $snmp::params::trap_sysconfig,
      content => template("snmp/snmptrapd.sysconfig-${::osfamily}.erb"),
      require => Package['snmpd'],
      notify  => Service['snmptrapd'],
    }

    service { 'snmptrapd':
      ensure     => $service_ensure_real,
      name       => $trap_service_name,
      enable     => $service_enable_real,
      hasstatus  => $trap_service_hasstatus,
      hasrestart => $trap_service_hasrestart,
      require    => [ Package['snmpd'], File['var-net-snmp'], ],
    }
  }

  service { 'snmpd':
    ensure     => $service_ensure_real,
    name       => $service_name,
    enable     => $service_enable_real,
    hasstatus  => $service_hasstatus,
    hasrestart => $service_hasrestart,
    require    => [ Package['snmpd'], File['var-net-snmp'], ],
  }
}
