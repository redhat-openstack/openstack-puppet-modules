# == Class: hiera
#
# This class handles installing the hiera.yaml for Puppet's use.
#
# === Parameters:
#
# [*hierarchy*]
#   Hiera hierarchy.
#   Default: empty
#
# [*backends*]
#   Hiera backends.
#   Default: ['yaml']
#
# [*hiera_yaml*]
#   Heira config file.
#   Default: auto-set, platform specific
#
# [*datadir*]
#   Directory in which hiera will start looking for databases.
#   Default: auto-set, platform specific
#
# [*owner*]
#   Owner of the files.
#   Default: auto-set, platform specific
#
# [*group*]
#   Group owner of the files.
#   Default: auto-set, platform specific
#
# [*extra_config*]
#   An extra string fragment of YAML to append to the config file.
#   Useful for configuring backend-specific parameters.
#   Default: ''
#
# [*eyaml*]
#   Install and configure hiera-eyaml
#   Default: false
#
# [*eyaml_datadir*]
#   Location of eyaml-specific data
#   Default: Same as datadir
#
# === Actions:
#
# Installs either /etc/puppet/hiera.yaml or /etc/puppetlabs/puppet/hiera.yaml.
# Links /etc/hiera.yaml to the above file.
# Creates $datadir.
#
# === Requires:
#
# Nothing.
#
# === Sample Usage:
#
#   class { 'hiera':
#     hierarchy => [
#       '%{environment}',
#       'common',
#     ],
#   }
#
# === Authors:
#
# Hunter Haugen <h.haugen@gmail.com>
# Mike Arnold <mike@razorsedge.org>
# Terri Haber <terri@puppetlabs.com>
#
# === Copyright:
#
# Copyright (C) 2012 Hunter Haugen, unless otherwise noted.
# Copyright (C) 2013 Mike Arnold, unless otherwise noted.
# Copyright (C) 2014 Terri Haber, unless otherwise noted.
#
class hiera (
  $hierarchy     = [],
  $backends      = $hiera::params::backends,
  $hiera_yaml    = $hiera::params::hiera_yaml,
  $datadir       = $hiera::params::datadir,
  $owner         = $hiera::params::owner,
  $group         = $hiera::params::group,
  $eyaml         = false,
  $eyaml_datadir = $hiera::params::datadir,
  $confdir       = $hiera::params::confdir,
  $extra_config  = '',
) inherits hiera::params {
  File {
    owner => $owner,
    group => $group,
    mode  => '0644',
  }
  if $datadir !~ /%\{.*\}/ {
    file { $datadir:
      ensure => directory,
    }
  }
  if $eyaml {
    require hiera::eyaml
  }
  # Template uses $hierarchy, $datadir
  file { $hiera_yaml:
    ensure  => present,
    content => template('hiera/hiera.yaml.erb'),
  }
  # Symlink for hiera command line tool
  file { '/etc/hiera.yaml':
    ensure => symlink,
    target => $hiera_yaml,
  }  
}
