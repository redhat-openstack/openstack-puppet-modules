# == Class: sahara::service::all
#
# Installs & configure the Sahara combined API & Engine service
#
# === Parameters
#
# [*enabled*]
#   (Optional) Should the service be enabled.
#   Defaults to 'true'.
#
# [*manage_service*]
#   (Optional) Whether the service should be managed by Puppet.
#   Defaults to 'true'.
#
# [*package_ensure*]
#   (Optional) Ensure state for package.
#   Defaults to 'present'
#
class sahara::service::all (
  $enabled               = true,
  $manage_service        = true,
  $package_ensure        = 'present',
) {

  require ::sahara

  Sahara_config<||> ~> Service['sahara-all']
  Class['sahara::policy'] ~> Service['sahara-all']

  package { 'sahara-all':
    ensure => $package_ensure,
    name   => $::sahara::params::all_package_name,
    tag    => ['openstack', 'sahara-package'],
    notify => Service['sahara-all'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'sahara-all':
    ensure     => $service_ensure,
    name       => $::sahara::params::all_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['sahara-all'],
    tag        => 'sahara-service',
  }

}
