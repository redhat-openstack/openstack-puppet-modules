# Installs & configure the gnocchi statsd service
#
# == Parameters
#
# [*resource_id*]
#   (required) Resource UUID to use to identify statsd in Gnocchi.
#
# [*user_id*]
#   (required) User UUID to use to identify statsd in Gnocchi.
#
# [*project_id*]
#   (required) Project UUID to use to identify statsd in Gnocchi.
#
# [*flush_delay*]
#   (required) Delay between flushes.
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*archive_policy_name*]
#   (optional) Archive policy name to use when creating metrics.
#   Defaults to undef.
#
class gnocchi::statsd (
  $resource_id,
  $user_id,
  $project_id,
  $flush_delay,
  $archive_policy_name = undef,
  $manage_service      = true,
  $enabled             = true,
  $package_ensure      = 'present',
) inherits gnocchi::params {

  Gnocchi_config<||> ~> Service['gnocchi-statsd']
  Package['gnocchi-statsd'] -> Service['gnocchi-statsd']

  package { 'gnocchi-statsd':
    ensure => $package_ensure,
    name   => $::gnocchi::params::statsd_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'gnocchi-statsd':
    ensure     => $service_ensure,
    name       => $::gnocchi::params::statsd_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
  }

  gnocchi_config {
    'statsd/resource_id'         : value => $resource_id;
    'statsd/user_id'             : value => $user_id;
    'statsd/project_id'          : value => $project_id;
    'statsd/archive_policy_name' : value => $archive_policy_name;
    'statsd/flush_delay'         : value => $flush_delay;
  }

}
