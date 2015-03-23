# == Class: manila::share
#
# === Parameters
#
# [*package_ensure*]
#   (Optional) Ensure State for package
#   Defaults to 'present'.
#
# [*enabled*]
#   (Optional) Should the service be enabled
#   Defaults to true.
#
# [*manage_service*]
#   (Optional) Whether the service should be managed by Puppet
#   Defaults to true.
#
# $share_name_template = share-%s
class manila::share (
  $package_ensure = 'present',
  $enabled        = true,
  $manage_service = true
) {

  include ::manila::params

  Manila_config<||> ~> Service['manila-share']
  Manila_api_paste_ini<||> ~> Service['manila-share']
  Exec<| title == 'manila-manage db_sync' |> ~> Service['manila-share']

  if $::manila::params::share_package {
    Package['manila-share'] -> Manila_config<||>
    Package['manila-share'] -> Manila_api_paste_ini<||>
    Package['manila']        -> Package['manila-share']
    Package['manila-share'] -> Service['manila-share']
    package { 'manila-share':
      ensure => $package_ensure,
      name   => $::manila::params::share_package,
    }
  }

  if $manage_service {
    if $enabled {
      $ensure = 'running'
    } else {
      $ensure = 'stopped'
    }
  }

  service { 'manila-share':
    ensure    => $ensure,
    name      => $::manila::params::share_service,
    enable    => $enabled,
    hasstatus => true,
    require   => Package['manila'],
  }
}
