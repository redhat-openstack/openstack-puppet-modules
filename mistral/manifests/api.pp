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
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of mistral-api.
#   If the value is 'httpd', this means mistral-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'mistral::wsgi::apache'...}
#   to make mistral-api be a web app using apache mod_wsgi.
#   Defaults to '$::mistral::params::api_service_name'
#
class mistral::api (
  $package_ensure                  = present,
  $manage_service                  = true,
  $enabled                         = true,
  $bind_host                       = $::os_service_default,
  $bind_port                       = $::os_service_default,
  $allow_action_execution_deletion = $::os_service_default,
  $service_name                    = $::mistral::params::api_service_name,
) inherits mistral::params {

  include ::mistral::params
  include ::mistral::policy

  Mistral_config<||> ~> Service[$service_name]
  Class['mistral::policy'] ~> Service[$service_name]
  Package['mistral-api'] -> Class['mistral::policy']
  Package['mistral-api'] -> Service[$service_name]
  Package['mistral-api'] -> Service['mistral-api']

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

  if $service_name == $::mistral::params::api_service_name {
    service { 'mistral-api':
      ensure     => $service_ensure,
      name       => $::mistral::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      tag        => 'mistral-service',
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params
    service { 'mistral-api':
      ensure => 'stopped',
      name   => $::mistral::params::api_service_name,
      enable => false,
      tag    => 'mistral-service',
    }
    Class['mistral::db'] -> Service[$service_name]
    Service <<| title == 'httpd' |>> { tag +> 'mistral-service' }

    # we need to make sure mistral-api s stopped before trying to start apache
    Service['mistral-api'] -> Service[$service_name]
  } else {
    fail('Invalid service_name. Either mistral/openstack-mistral-api for running as a standalone service, or httpd for being run by a httpd server')
  }

  mistral_config {
    'api/host'                             : value => $bind_host;
    'api/port'                             : value => $bind_port;
    'api/allow_action_execution_deletion'  : value => $allow_action_execution_deletion;
  }

}
