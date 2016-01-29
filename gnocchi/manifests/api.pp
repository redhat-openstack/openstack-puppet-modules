# Installs & configure the gnocchi api service
#
# == Parameters
#
# [*enabled*]
#   (optional) Should the service be enabled.
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether the service should be managed by Puppet.
#   Defaults to true.
#
# [*keystone_user*]
#   (optional) The name of the auth user
#   Defaults to gnocchi
#
# [*keystone_tenant*]
#   (optional) Tenant to authenticate with.
#   Defaults to 'services'.
#
# [*keystone_password*]
#   Password to authenticate with.
#   Mandatory.
#
# [*keystone_auth_uri*]
#   (optional) Public Identity API endpoint.
#   Defaults to 'false'.
#
# [*keystone_identity_uri*]
#   (optional) Complete admin Identity API endpoint.
#   Defaults to: false
#
# [*host*]
#   (optional) The gnocchi api bind address.
#   Defaults to 0.0.0.0
#
# [*port*]
#   (optional) The gnocchi api port.
#   Defaults to 8041
#
# [*workers*]
#   (optional) Number of workers for Gnocchi API server.
#   Defaults to $::processorcount
#
# [*max_limit*]
#   (optional) The maximum number of items returned in a
#   single response from a collection resource.
#   Defaults to 1000
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of gnocchi-api.
#   If the value is 'httpd', this means gnocchi-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'gnocchi::wsgi::apache'...}
#   to make gnocchi-api be a web app using apache mod_wsgi.
#   Defaults to '$::gnocchi::params::api_service_name'
#
class gnocchi::api (
  $manage_service        = true,
  $enabled               = true,
  $package_ensure        = 'present',
  $keystone_user         = 'gnocchi',
  $keystone_tenant       = 'services',
  $keystone_password     = false,
  $keystone_auth_uri     = false,
  $keystone_identity_uri = false,
  $host                  = '0.0.0.0',
  $port                  = '8041',
  $workers               = $::processorcount,
  $max_limit             = 1000,
  $service_name          = $::gnocchi::params::api_service_name,
) inherits gnocchi::params {

  include ::gnocchi::policy

  validate_string($keystone_password)

  Gnocchi_config<||> ~> Service[$service_name]
  Gnocchi_api_paste_ini<||> ~> Service[$service_name]
  Class['gnocchi::policy'] ~> Service[$service_name]

  Package['gnocchi-api'] -> Service[$service_name]
  Package['gnocchi-api'] -> Service['gnocchi-api']
  Package['gnocchi-api'] -> Class['gnocchi::policy']
  package { 'gnocchi-api':
    ensure => $package_ensure,
    name   => $::gnocchi::params::api_package_name,
    tag    => ['openstack', 'gnocchi-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $service_name == $::gnocchi::params::api_service_name {
    service { 'gnocchi-api':
      ensure     => $service_ensure,
      name       => $::gnocchi::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      require    => Class['gnocchi::db'],
      tag        => ['gnocchi-service', 'gnocchi-db-sync-service'],
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params
    service { 'gnocchi-api':
      ensure => 'stopped',
      name   => $::gnocchi::params::api_service_name,
      enable => false,
      tag    => ['gnocchi-service', 'gnocchi-db-sync-service'],
    }
    Class['gnocchi::db'] -> Service[$service_name]
    Service <<| title == 'httpd' |>> { tag +> 'gnocchi-db-sync-service' }

    # we need to make sure gnocchi-api/eventlet is stopped before trying to start apache
    Service['gnocchi-api'] -> Service[$service_name]
  } else {
    fail('Invalid service_name. Either gnocchi/openstack-gnocchi-api for running as a standalone service, or httpd for being run by a httpd server')
  }

  gnocchi_config {
    'keystone_authtoken/auth_uri'          : value => $keystone_auth_uri;
    'keystone_authtoken/admin_tenant_name' : value => $keystone_tenant;
    'keystone_authtoken/admin_user'        : value => $keystone_user;
    'keystone_authtoken/admin_password'    : value => $keystone_password, secret => true;
    'api/host'                             : value => $host;
    'api/port'                             : value => $port;
    'api/workers'                          : value => $workers;
    'api/max_limit'                        : value => $max_limit;
  }

  if $keystone_identity_uri {
    gnocchi_config {
      'keystone_authtoken/identity_uri': value => $keystone_identity_uri;
    }
    gnocchi_api_paste_ini {
      'pipeline:main/pipeline':  value => 'keystone_authtoken gnocchi',
    }
  } else {
    gnocchi_config {
      'keystone_authtoken/identity_uri': ensure => absent;
    }
  }

}
