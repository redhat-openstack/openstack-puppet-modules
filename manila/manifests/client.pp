# == Class: manila::client
#
# Installs Manila python client.
#
# === Parameters
#
# [*package_ensure*]
#   Ensure state for package. Defaults to 'present'.
#
class manila::client (
  $package_ensure = 'present'
) {

  include ::manila::params

  package { 'python-manilaclient':
    ensure => $package_ensure,
    name   => $::manila::params::client_package,
  }
}
