# Installs & configure the aodh api service
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
#   Defaults to aodh
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
#   (optional) The aodh api bind address.
#   Defaults to 0.0.0.0
#
# [*port*]
#   (optional) The aodh api port.
#   Defaults to 8777
#
# [*package_ensure*]
#   (optional) ensure state for package.
#   Defaults to 'present'
#
# [*service_name*]
#   (optional) Name of the service that will be providing the
#   server functionality of aodh-api.
#   If the value is 'httpd', this means aodh-api will be a web
#   service, and you must use another class to configure that
#   web service. For example, use class { 'aodh::wsgi::apache'...}
#   to make aodh-api be a web app using apache mod_wsgi.
#   Defaults to '$::aodh::params::api_service_name'
#
class aodh::api (
  $manage_service        = true,
  $enabled               = true,
  $package_ensure        = 'present',
  $keystone_user         = 'aodh',
  $keystone_tenant       = 'services',
  $keystone_password     = false,
  $keystone_auth_uri     = false,
  $keystone_identity_uri = false,
  $host                  = '0.0.0.0',
  $port                  = '8777',
  $service_name          = $::aodh::params::api_service_name,
) inherits aodh::params {

  include ::aodh::params
  include ::aodh::policy

  validate_string($keystone_password)

  Aodh_config<||> ~> Service[$service_name]
  Class['aodh::policy'] ~> Service[$service_name]

  Package['aodh-api'] -> Service[$service_name]
  Package['aodh-api'] -> Service['aodh-api']
  Package['aodh-api'] -> Class['aodh::policy']
  package { 'aodh-api':
    ensure => $package_ensure,
    name   => $::aodh::params::api_package_name,
    tag    => ['openstack', 'aodh-package'],
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $service_name == $::aodh::params::api_service_name {
    service { 'aodh-api':
      ensure     => $service_ensure,
      name       => $::aodh::params::api_service_name,
      enable     => $enabled,
      hasstatus  => true,
      hasrestart => true,
      require    => Class['aodh::db'],
      tag        => 'aodh-service',
    }
  } elsif $service_name == 'httpd' {
    include ::apache::params
    service { 'aodh-api':
      ensure => 'stopped',
      name   => $::aodh::params::api_service_name,
      enable => false,
      tag    => 'aodh-service',
    }
    Class['aodh::db'] -> Service[$service_name]

    # we need to make sure aodh-api/eventlet is stopped before trying to start apache
    Service['aodh-api'] -> Service[$service_name]
  } else {
    fail('Invalid service_name. Either aodh/openstack-aodh-api for running as a standalone service, or httpd for being run by a httpd server')
  }

  aodh_config {
    'keystone_authtoken/auth_uri'          : value => $keystone_auth_uri;
    'keystone_authtoken/admin_tenant_name' : value => $keystone_tenant;
    'keystone_authtoken/admin_user'        : value => $keystone_user;
    'keystone_authtoken/admin_password'    : value => $keystone_password, secret => true;
    'api/host'                             : value => $host;
    'api/port'                             : value => $port;
  }

  if $keystone_identity_uri {
    aodh_config {
      'keystone_authtoken/identity_uri': value => $keystone_identity_uri;
    }
  } else {
    aodh_config {
      'keystone_authtoken/identity_uri': ensure => absent;
    }
  }

}
