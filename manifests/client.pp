# == Class: snmp::client
#
# This class handles installing the Net-SNMP client.
#
# === Parameters:
#
# [*snmp_config*]
#   Array of lines to add to the client's global snmp.conf file.
#   See http://www.net-snmp.org/docs/man/snmp.conf.html for all options.
#   Default: []
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
# Installs the Net-SNMP client package and configuration.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'snmp::client':
#     snmp_config => [ 'defVersion 2c', 'defCommunity public', ],
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
class snmp::client (
  $snmp_config        = $snmp::params::snmp_config,
  $ensure             = $snmp::params::ensure,
  $autoupgrade        = $snmp::params::safe_autoupgrade,
  $package_name       = $snmp::params::client_package_name
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

  if $::osfamily != 'Suse' {
    package { 'snmp-client':
      ensure => $package_ensure,
      name   => $package_name,
    }
    $req = Package['snmp-client']
  } else {
    $req = undef
  }

  file { 'snmp.conf':
    ensure  => $file_ensure,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    path    => $snmp::params::client_config,
    content => template('snmp/snmp.conf.erb'),
    require => $req,
  }
}
