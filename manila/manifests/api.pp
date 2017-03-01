# == Class: manila::api
#
# Setup and configure the manila API endpoint
#
# === Parameters
#
# [*keystone_password*]
#   The password to use for authentication (keystone)
#
# [*keystone_enabled*]
#   (optional) Use keystone for authentification
#   Defaults to true
#
# [*keystone_tenant*]
#   (optional) The tenant of the auth user
#   Defaults to services
#
# [*keystone_user*]
#   (optional) The name of the auth user
#   Defaults to manila
#
# [*keystone_auth_host*]
#   (optional) The keystone host
#   Defaults to localhost
#
# [*keystone_auth_port*]
#   (optional) The keystone auth port
#   Defaults to 35357
#
# [*keystone_auth_protocol*]
#   (optional) The protocol used to access the auth host
#   Defaults to http.
#
# [*os_region_name*]
#   (optional) Some operations require manila to make API requests
#   to Nova. This sets the keystone region to be used for these
#   requests. For example, boot-from-share.
#   Defaults to undef.
#
# [*keystone_auth_admin_prefix*]
#   (optional) The admin_prefix used to admin endpoint of the auth host
#   This allow admin auth URIs like http://auth_host:35357/keystone.
#   (where '/keystone' is the admin prefix)
#   Defaults to false for empty. If defined, should be a string with a
#   leading '/' and no trailing '/'.
#
# [*keystone_auth_uri*]
#   (Optional) Public Identity API endpoint.
#   Defaults to false.
#
# [*service_port*]
#   (optional) The manila api port
#   Defaults to 5000
#
# [*package_ensure*]
#   (optional) The state of the package
#   Defaults to present
#
# [*bind_host*]
#   (optional) The manila api bind address
#   Defaults to 0.0.0.0
#
# [*enabled*]
#   (optional) The state of the service
#   Defaults to true
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*ratelimits*]
#   (optional) The state of the service
#   Defaults to undef. If undefined the default ratelimiting values are used.
#
# [*ratelimits_factory*]
#   (optional) Factory to use for ratelimiting
#   Defaults to 'manila.api.v1.limits:RateLimitingMiddleware.factory'
#
class manila::api (
  $keystone_password,
  $keystone_enabled           = true,
  $keystone_tenant            = 'services',
  $keystone_user              = 'manila',
  $keystone_auth_host         = 'localhost',
  $keystone_auth_port         = '35357',
  $keystone_auth_protocol     = 'http',
  $keystone_auth_admin_prefix = false,
  $keystone_auth_uri          = false,
  $os_region_name             = undef,
  $service_port               = '5000',
  $package_ensure             = 'present',
  $bind_host                  = '0.0.0.0',
  $enabled                    = true,
  $manage_service             = true,
  $ratelimits                 = undef,
  $ratelimits_factory =
    'manila.api.v1.limits:RateLimitingMiddleware.factory'
) {

  include ::manila::params

  Manila_config<||> ~> Service['manila-api']
  Manila_api_paste_ini<||> ~> Service['manila-api']

  if $::manila::params::api_package {
    Package['manila-api'] -> Manila_config<||>
    Package['manila-api'] -> Manila_api_paste_ini<||>
    Package['manila-api'] -> Service['manila-api']
    package { 'manila-api':
      ensure => $package_ensure,
      name   => $::manila::params::api_package,
    }
  }

  if $enabled {

    Manila_config<||> ~> Exec['manila-manage db_sync']

    exec { 'manila-manage db_sync':
      command     => $::manila::params::db_sync_command,
      path        => '/usr/bin',
      user        => 'manila',
      refreshonly => true,
      logoutput   => 'on_failure',
      require     => Package['manila'],
    }
    if $manage_service {
      $ensure = 'running'
    }
  } else {
    if $manage_service {
      $ensure = 'stopped'
    }
  }

  service { 'manila-api':
    ensure    => $ensure,
    name      => $::manila::params::api_service,
    enable    => $enabled,
    hasstatus => true,
    require   => Package['manila'],
  }

  manila_config {
    'DEFAULT/osapi_share_listen': value => $bind_host,
  }

  if $os_region_name {
    manila_config {
      'DEFAULT/os_region_name': value => $os_region_name;
    }
  }

  if $keystone_auth_uri {
    manila_api_paste_ini { 'filter:authtoken/auth_uri': value => $keystone_auth_uri; }
  } else {
    manila_api_paste_ini { 'filter:authtoken/auth_uri': value => "${keystone_auth_protocol}://${keystone_auth_host}:${service_port}/"; }
  }

  if $keystone_enabled {
    manila_config {
      'DEFAULT/auth_strategy':     value => 'keystone' ;
    }
    manila_api_paste_ini {
      'filter:authtoken/service_protocol':  value => $keystone_auth_protocol;
      'filter:authtoken/service_host':      value => $keystone_auth_host;
      'filter:authtoken/service_port':      value => $service_port;
      'filter:authtoken/auth_protocol':     value => $keystone_auth_protocol;
      'filter:authtoken/auth_host':         value => $keystone_auth_host;
      'filter:authtoken/auth_port':         value => $keystone_auth_port;
      'filter:authtoken/admin_tenant_name': value => $keystone_tenant;
      'filter:authtoken/admin_user':        value => $keystone_user;
      'filter:authtoken/admin_password':    value => $keystone_password, secret => true;
    }

  if ($ratelimits != undef) {
    manila_api_paste_ini {
      'filter:ratelimit/paste.filter_factory': value => $ratelimits_factory;
      'filter:ratelimit/limits':               value => $ratelimits;
    }
  }

    if $keystone_auth_admin_prefix {
      validate_re($keystone_auth_admin_prefix, '^(/.+[^/])?$')
      manila_api_paste_ini {
        'filter:authtoken/auth_admin_prefix': value => $keystone_auth_admin_prefix;
      }
    } else {
      manila_api_paste_ini {
        'filter:authtoken/auth_admin_prefix': ensure => absent;
      }
    }
  }

}
