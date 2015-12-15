# == Class: glance::registry
#
# Installs and configures glance-registry
#
# === Parameters
#
#  [*keystone_password*]
#    (required) The keystone password for administrative user
#
#  [*package_ensure*]
#    (optional) Ensure state for package. Defaults to 'present'.  On RedHat
#    platforms this setting is ignored and the setting from the glance class is
#    used because there is only one glance package.
#
#  [*verbose*]
#    (optional) Enable verbose logs (true|false). Defaults to undef.
#
#  [*debug*]
#    (optional) Enable debug logs (true|false). Defaults to undef.
#
#  [*bind_host*]
#    (optional) The address of the host to bind to. Defaults to '0.0.0.0'.
#
#  [*bind_port*]
#    (optional) The port the server should bind to. Defaults to '9191'.
#
#  [*workers*]
#    (optional) The number of child process workers that will be
#    created to service Registry requests.
#    Defaults to: $::processorcount
#
#  [*log_file*]
#    (optional) Log file for glance-registry.
#    If set to boolean false, it will not log to any file.
#    Defaults to undef.
#
#  [*log_dir*]
#    (optional) directory to which glance logs are sent.
#    If set to boolean false, it will not log to any directory.
#    Defaults to undef.
#
#  [*database_connection*]
#    (optional) Connection url to connect to nova database.
#    Defaults to undef
#
#  [*database_idle_timeout*]
#    (optional) Timeout before idle db connections are reaped.
#    Defaults to undef
#
#  [*database_max_retries*]
#    (Optional) Maximum number of database connection retries during startup.
#    Set to -1 to specify an infinite retry count.
#    Defaults to undef.
#
#  [*database_retry_interval*]
#    (optional) Interval between retries of opening a database connection.
#    Defaults to undef.
#
#  [*database_min_pool_size*]
#    (optional) Minimum number of SQL connections to keep open in a pool.
#    Defaults to undef.
#
#  [*database_max_pool_size*]
#    (optional) Maximum number of SQL connections to keep open in a pool.
#    Defaults to undef.
#
#  [*database_max_overflow*]
#    (optional) If set, use this value for max_overflow with sqlalchemy.
#    Defaults to undef.
#
#  [*auth_type*]
#    (optional) Authentication type. Defaults to 'keystone'.
#
#  [*auth_host*]
#    (optional) DEPRECATED Address of the admin authentication endpoint.
#    Defaults to '127.0.0.1'.
#
#  [*auth_port*]
#    (optional) DEPRECATED Port of the admin authentication endpoint. Defaults to '35357'.
#
#  [*auth_admin_prefix*]
#    (optional) DEPRECATED path part of the auth url.
#    This allow admin auth URIs like http://auth_host:35357/keystone/admin.
#    (where '/keystone/admin' is auth_admin_prefix)
#    Defaults to false for empty. If defined, should be a string with a leading '/' and no trailing '/'.
#
#  [*auth_protocol*]
#    (optional) DEPRECATED Protocol to communicate with the admin authentication endpoint.
#    Defaults to 'http'. Should be 'http' or 'https'.
#
#  [*auth_uri*]
#    (optional) Complete public Identity API endpoint.
#
#  [*identity_uri*]
#    (optional) Complete admin Identity API endpoint.
#    Defaults to: false
#
#  [*keystone_tenant*]
#    (optional) administrative tenant name to connect to keystone.
#    Defaults to 'services'.
#
#  [*keystone_user*]
#    (optional) administrative user name to connect to keystone.
#    Defaults to 'glance'.
#
#  [*pipeline*]
#    (optional) Partial name of a pipeline in your paste configuration
#     file with the service name removed.
#     Defaults to 'keystone'.
#
#  [*use_syslog*]
#    (optional) Use syslog for logging.
#    Defaults to undef.
#
#  [*use_stderr*]
#    (optional) Use stderr for logging
#    Defaults to undef.
#
#  [*log_facility*]
#    (optional) Syslog facility to receive log lines.
#    Defaults to undef.
#
#  [*manage_service*]
#    (optional) If Puppet should manage service startup / shutdown.
#    Defaults to true.
#
#  [*enabled*]
#    (optional) Should the service be enabled.
#    Defaults to true.
#
#  [*purge_config*]
#    (optional) Whether to create only the specified config values in
#    the glance registry config file.
#    Defaults to false.
#
# [*cert_file*]
#   (optinal) Certificate file to use when starting registry server securely
#   Defaults to false, not set
#
# [*key_file*]
#   (optional) Private key file to use when starting registry server securely
#   Defaults to false, not set
#
# [*ca_file*]
#   (optional) CA certificate file to use to verify connecting clients
#   Defaults to false, not set
#
# [*sync_db*]
#   (Optional) Run db sync on the node.
#   Defaults to true
#
#  [*os_region_name*]
#    (optional) Sets the keystone region to use.
#    Defaults to 'RegionOne'.
#
#  [*signing_dir*]
#    Directory used to cache files related to PKI tokens.
#    Defaults to $::os_service_default.
#
#  [*token_cache_time*]
#    In order to prevent excessive effort spent validating tokens,
#    the middleware caches previously-seen tokens for a configurable duration (in seconds).
#    Set to -1 to disable caching completely.
#    Defaults to $::os_service_default.
#
class glance::registry(
  $keystone_password,
  $package_ensure          = 'present',
  $verbose                 = undef,
  $debug                   = undef,
  $bind_host               = '0.0.0.0',
  $bind_port               = '9191',
  $workers                 = $::processorcount,
  $log_file                = undef,
  $log_dir                 = undef,
  $database_connection     = undef,
  $database_idle_timeout   = undef,
  $database_min_pool_size  = undef,
  $database_max_pool_size  = undef,
  $database_max_retries    = undef,
  $database_retry_interval = undef,
  $database_max_overflow   = undef,
  $auth_type               = 'keystone',
  $auth_uri                = false,
  $identity_uri            = false,
  $keystone_tenant         = 'services',
  $keystone_user           = 'glance',
  $pipeline                = 'keystone',
  $use_syslog              = undef,
  $use_stderr              = undef,
  $log_facility            = undef,
  $manage_service          = true,
  $enabled                 = true,
  $purge_config            = false,
  $cert_file               = false,
  $key_file                = false,
  $ca_file                 = false,
  $sync_db                 = true,
  $os_region_name          = 'RegionOne',
  $signing_dir             = $::os_service_default,
  $token_cache_time        = $::os_service_default,
  # DEPRECATED PARAMETERS
  $auth_host               = '127.0.0.1',
  $auth_port               = '35357',
  $auth_admin_prefix       = false,
  $auth_protocol           = 'http',
) inherits glance {

  include ::glance::registry::logging
  include ::glance::registry::db
  require keystone::python

  if ( $glance::params::api_package_name != $glance::params::registry_package_name ) {
    ensure_packages( 'glance-registry',
      {
        ensure => $package_ensure,
        tag    => ['openstack', 'glance-package'],
      }
    )
  }

  Package[$glance::params::registry_package_name] -> File['/etc/glance/']

  Glance_registry_config<||> ~> Service['glance-registry']

  File {
    ensure  => present,
    owner   => 'glance',
    group   => 'glance',
    mode    => '0640',
    notify  => Service['glance-registry'],
    require => Class['glance']
  }

  warning('Default value for os_region_name parameter is different from OpenStack project defaults')

  glance_registry_config {
    'DEFAULT/workers':                value => $workers;
    'DEFAULT/bind_host':              value => $bind_host;
    'DEFAULT/bind_port':              value => $bind_port;
    'glance_store/os_region_name':    value => $os_region_name;
  }

  if $identity_uri {
    glance_registry_config { 'keystone_authtoken/identity_uri': value => $identity_uri; }
  } else {
    glance_registry_config { 'keystone_authtoken/identity_uri': ensure => absent; }
  }

  if $auth_uri {
    glance_registry_config { 'keystone_authtoken/auth_uri': value => $auth_uri; }
  } else {
    glance_registry_config { 'keystone_authtoken/auth_uri': value => "${auth_protocol}://${auth_host}:5000/"; }
  }

  # if both auth_uri and identity_uri are set we skip these deprecated settings entirely
  if !$auth_uri or !$identity_uri {

    if $auth_host {
      warning('The auth_host parameter is deprecated. Please use auth_uri and identity_uri instead.')
      glance_registry_config { 'keystone_authtoken/auth_host': value => $auth_host; }
    } else {
      glance_registry_config { 'keystone_authtoken/auth_host': ensure => absent; }
    }

    if $auth_port {
      warning('The auth_port parameter is deprecated. Please use auth_uri and identity_uri instead.')
      glance_registry_config { 'keystone_authtoken/auth_port': value => $auth_port; }
    } else {
      glance_registry_config { 'keystone_authtoken/auth_port': ensure => absent; }
    }

    if $auth_protocol {
      warning('The auth_protocol parameter is deprecated. Please use auth_uri and identity_uri instead.')
      glance_registry_config { 'keystone_authtoken/auth_protocol': value => $auth_protocol; }
    } else {
      glance_registry_config { 'keystone_authtoken/auth_protocol': ensure => absent; }
    }

    if $auth_admin_prefix {
      warning('The auth_admin_prefix  parameter is deprecated. Please use auth_uri and identity_uri instead.')
      validate_re($auth_admin_prefix, '^(/.+[^/])?$')
      glance_registry_config {
        'keystone_authtoken/auth_admin_prefix': value => $auth_admin_prefix;
      }
    } else {
      glance_registry_config { 'keystone_authtoken/auth_admin_prefix': ensure => absent; }
    }

  } else {
    glance_registry_config {
      'keystone_authtoken/auth_host': ensure => absent;
      'keystone_authtoken/auth_port': ensure => absent;
      'keystone_authtoken/auth_protocol': ensure => absent;
      'keystone_authtoken/auth_admin_prefix': ensure => absent;
    }
  }

  # Set the pipeline, it is allowed to be blank
  if $pipeline != '' {
    validate_re($pipeline, '^(\w+([+]\w+)*)*$')
    glance_registry_config {
      'paste_deploy/flavor':
        ensure => present,
        value  => $pipeline,
    }
  } else {
    glance_registry_config { 'paste_deploy/flavor': ensure => absent }
  }

  # keystone config
  if $auth_type == 'keystone' {
    glance_registry_config {
      'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
      'keystone_authtoken/admin_user':        value => $keystone_user;
      'keystone_authtoken/admin_password':    value => $keystone_password, secret => true;
      'keystone_authtoken/token_cache_time':  value => $token_cache_time;
      'keystone_authtoken/signing_dir':       value => $signing_dir;
    }
  }

  # SSL Options
  if $cert_file {
    glance_registry_config {
      'DEFAULT/cert_file' : value => $cert_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/cert_file': ensure => absent;
    }
  }
  if $key_file {
    glance_registry_config {
      'DEFAULT/key_file'  : value => $key_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/key_file': ensure => absent;
    }
  }
  if $ca_file {
    glance_registry_config {
      'DEFAULT/ca_file'   : value => $ca_file;
    }
  } else {
    glance_registry_config {
      'DEFAULT/ca_file': ensure => absent;
    }
  }

  resources { 'glance_registry_config':
    purge => $purge_config
  }

  file { ['/etc/glance/glance-registry.conf',
          '/etc/glance/glance-registry-paste.ini']:
  }

  if $sync_db {
    include ::glance::db::sync
  }

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  } else {
    warning('Execution of db_sync does not depend on $manage_service or $enabled anymore. Please use sync_db instead.')
  }

  service { 'glance-registry':
    ensure     => $service_ensure,
    name       => $::glance::params::registry_service_name,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/glance/glance-registry.conf'],
    require    => Class['glance'],
    tag        => 'glance-service',
  }

}
