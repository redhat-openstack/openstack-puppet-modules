# == Class: mistral::api
#
# Installs & configure the Mistral API service
#
# === Parameters
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to present
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to 'true'.
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to 'true'.
#
# [*bind_host*]
#   (Optional) Address to bind the server. Useful when
#   selecting a particular network interface.
#   Defaults to $::os_service_default.
#
# [*bind_port*]
#   (Optional) The port on which the server will listen.
#   Defaults to $::os_service_default.
#
# [*allow_action_execution_deletion*]
#   (Optional) Enables the ability to delete action_execution which has no
#   relationship with workflows. (boolean value).
#   Defaults to $::os_service_default.
#
class mistral::api (
  $package_ensure                  = present,
  $manage_service                  = true,
  $enabled                         = true,
  $bind_host                       = $::os_service_default,
  $bind_port                       = $::os_service_default,
  $allow_action_execution_deletion = $::os_service_default,
) {

  include ::mistral::params
  include ::mistral::policy

  Package['mistral-api'] -> Class['mistral::policy']
  Class['mistral::policy'] ~> Service['mistral-api']

  package { 'mistral-api':
    ensure => $package_ensure,
    name   => $::mistral::params::api_package_name,
    tag    => ['openstack', 'mistral-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  service { 'mistral-api':
    ensure     => $service_ensure,
    name       => $::mistral::params::api_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    tag        => 'mistral-service',
  }

  mistral_config {
    'api/host'                             : value => $bind_host;
    'api/port'                             : value => $bind_port;
    'api/allow_action_execution_deletion'  : value => $allow_action_execution_deletion;
  }

}
