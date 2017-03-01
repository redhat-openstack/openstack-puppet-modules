# == Class: manila::scheduler
#
# Install and manage Manila scheduler.
#
# === Parameters
#
# [*scheduler_driver*]
#   (Optional) Description
#   Defaults to false.
#
# [*package_ensure*]
#   (Optional) The state of the scheduler package
#   Defaults to 'present'.
#
# [*enabled*]
#   (Optional) Whether to run the scheduler service
#   Defaults to true.
#
# [*manage_service*]
#   (Optional) Whether to start/stop the service
#   Defaults to true.
#
class manila::scheduler (
  $scheduler_driver = false,
  $package_ensure   = 'present',
  $enabled          = true,
  $manage_service   = true
) {

  include ::manila::params

  Manila_config<||> ~> Service['manila-scheduler']
  Manila_api_paste_ini<||> ~> Service['manila-scheduler']
  Exec<| title == 'manila-manage db_sync' |> ~> Service['manila-scheduler']

  if $scheduler_driver {
    manila_config {
      'DEFAULT/scheduler_driver': value => $scheduler_driver;
    }
  }

  if $::manila::params::scheduler_package {
    Package['manila-scheduler'] -> Manila_config<||>
    Package['manila-scheduler'] -> Manila_api_paste_ini<||>
    Package['manila-scheduler'] -> Service['manila-scheduler']
    package { 'manila-scheduler':
      ensure => $package_ensure,
      name   => $::manila::params::scheduler_package,
    }
  }

  if $manage_service {
    if $enabled {
      $ensure = 'running'
    } else {
      $ensure = 'stopped'
    }
  }

  service { 'manila-scheduler':
    ensure    => $ensure,
    name      => $::manila::params::scheduler_service,
    enable    => $enabled,
    hasstatus => true,
    require   => Package['manila'],
  }
}
