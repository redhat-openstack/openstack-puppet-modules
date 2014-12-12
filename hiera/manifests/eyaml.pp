# == Class: hiera::eyaml
#
# This class installs and configures hiera-eyaml
#
# === Authors:
#
# Terri Haber <terri@puppetlabs.com>
#
# === Copyright:
#
# Copyright (C) 2014 Terri Haber, unless otherwise noted.
#
class hiera::eyaml (
  $provider = $hiera::params::provider,
  $owner    = $hiera::params::owner,
  $group    = $hiera::params::group,
  $cmdpath  = $hiera::params::cmdpath,
  $confdir  = $hiera::params::confdir
) inherits hiera::params {

  package { 'hiera-eyaml':
    ensure   => installed,
    provider => $provider,
  }

  file { "${confdir}/keys":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    before => Exec['createkeys'],
  }

  exec { 'createkeys':
    user    => $owner,
    cwd     => $confdir,
    command => "${cmdpath}/eyaml createkeys",
    path    => $cmdpath,
    creates => "${confdir}/keys/private_key.pkcs7.pem",
    require => Package['hiera-eyaml'],
  }

  $eyaml_files = [
    "${confdir}/keys/private_key.pkcs7.pem",
    "${confdir}/keys/public_key.pkcs7.pem"]

  file { $eyaml_files:
    ensure  => file,
    mode    => '0604',
    owner   => $owner,
    group   => $group,
    require => Exec['createkeys'],
  }
}
