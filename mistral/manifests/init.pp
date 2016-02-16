# == Class: mistral
#
# Mistral base package & configuration
#
# === Parameters
# [*package_ensure*]
#   (Optional) Ensure state for package.
#   Defaults to 'present'.
#
# [*rpc_backend*]
#   (optional) The rpc backend.
#   Defaults to 'rabbit'.
#
# [*auth_uri*]
#   (optional) Specifies the public Identity URI for Mistral to use.
#   Default 'http://localhost:5000/v2.0/'.
#
# [*identity_uri*]
#   (optional) Specifies the admin Identity URI for Mistral to use.
#   Default 'http://localhost:35357/'.
#
# [*keystone_user*]
#   (optional) The name of the auth user
#   Defaults to 'mistral'.
#
# [*keystone_tenant*]
#   (optional) The tenant of the auth user
#   Defaults to 'services'.
#
# [*keystone_password*]
#   (required) The password of the auth user.
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false or the $::os_service_default, it will not log to
#   any directory.
#   Defaults to '/var/log/mistral'.
#
# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to undef.
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef.
#
# [*log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   Defaults to undef.
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to undef.
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to undef.
#
# [*database_connection*]
#   (optional) Url used to connect to database.
#   Defaults to undef.
#
# [*database_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to undef.
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to undef.
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to undef.
#
# [*database_max_retries*]
#   Maximum db connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to undef.
#
# [*database_retry_interval*]
#   Interval between retries of opening a sql connection.
#   (Optional) Defaults to underf.
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to undef.
#
# [*rabbit_host*]
#   (Optional) IP or hostname of the rabbit server.
#   Defaults to '127.0.0.1'
#
# [*rabbit_port*]
#   (Optional) Port of the rabbit server.
#   Defaults to 5672.
#
# [*rabbit_hosts*]
#   (Optional) Array of host:port (used with HA queues).
#   If defined, will remove rabbit_host & rabbit_port parameters from config
#   Defaults to undef.
#
# [*rabbit_userid*]
#   (Optional) User to connect to the rabbit server.
#   Defaults to 'guest'
#
# [*rabbit_password*]
#   (Required) Password to connect to the rabbit_server.
#   Defaults to empty. Required if using the Rabbit (kombu)
#   backend.
#
# [*rabbit_virtual_host*]
#   (Optional) Virtual_host to use.
#   Defaults to '/'
#
# [*rabbit_ha_queues*]
#   (optional) Use HA queues in RabbitMQ (x-ha-policy: all).
#   Defaults to undef
#
# [*rabbit_heartbeat_timeout_threshold*]
#   (optional) Number of seconds after which the RabbitMQ broker is considered
#   down if the heartbeat keepalive fails.  Any value >0 enables heartbeats.
#   Heartbeating helps to ensure the TCP connection to RabbitMQ isn't silently
#   closed, resulting in missed or lost messages from the queue.
#   (Requires kombu >= 3.0.7 and amqp >= 1.4.0)
#   Defaults to 0
#
# [*rabbit_heartbeat_rate*]
#   (optional) How often during the rabbit_heartbeat_timeout_threshold period to
#   check the heartbeat on RabbitMQ connection.  (i.e. rabbit_heartbeat_rate=2
#   when rabbit_heartbeat_timeout_threshold=60, the heartbeat will be checked
#   every 30 seconds.
#   Defaults to 2
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to false
#
# [*report_interval*]
#  (optional) Interval, in seconds, between nodes reporting state to
#  datastore (integer value).
#  Defaults to $::os_service_default
#
# [*service_down_time*]
#  (optional) Maximum time since last check-in for a service to be
#  considered up (integer value).
#  Defaults to $::os_service_default
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to $::os_service_default
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to $::os_service_default
#
# [*kombu_reconnect_delay*]
#   (optional) How long to wait before reconnecting in response to an AMQP
#   consumer cancel notification.
#   Defaults to $::os_service_default
#
# [*amqp_durable_queues*]
#   Use durable queues in amqp.
#   (Optional) Defaults to false.
#
# [*control_exchange*]
#   (Optional)
#   Defaults to 'openstack'.
#
# [*coordination_backend_url*]
#   (optional) The backend URL to be used for coordination.
#   Defaults to $::os_service_default
#
# [*coordination_heartbeat_interval*]
#   (optional) Number of seconds between heartbeats for coordination.
#   Defaults to $::os_service_default
#
class mistral(
  $keystone_password,
  $keystone_user                      = 'mistral',
  $keystone_tenant                    = 'services',
  $package_ensure                     = 'present',
  $database_connection                = undef,
  $rpc_backend                        = 'rabbit',
  $auth_uri                           = 'http://localhost:5000/',
  $identity_uri                       = 'http://localhost:35357/',
  $control_exchange                   = 'openstack',
  $rabbit_host                        = '127.0.0.1',
  $rabbit_port                        = 5672,
  $rabbit_hosts                       = undef,
  $rabbit_virtual_host                = '/',
  $rabbit_ha_queues                   = undef,
  $rabbit_heartbeat_timeout_threshold = 0,
  $rabbit_heartbeat_rate              = 2,
  $rabbit_userid                      = 'guest',
  $rabbit_password                    = false,
  $rabbit_use_ssl                     = false,
  $service_down_time                  = $::os_service_default,
  $report_interval                    = $::os_service_default,
  $kombu_ssl_ca_certs                 = $::os_service_default,
  $kombu_ssl_certfile                 = $::os_service_default,
  $kombu_ssl_keyfile                  = $::os_service_default,
  $kombu_ssl_version                  = $::os_service_default,
  $kombu_reconnect_delay              = $::os_service_default,
  $amqp_durable_queues                = false,
  $use_syslog                         = undef,
  $use_stderr                         = undef,
  $log_dir                            = '/var/log/mistral',
  $log_facility                       = undef,
  $verbose                            = undef,
  $debug                              = undef,
  $coordination_backend_url           = $::os_service_default,
  $coordination_heartbeat_interval    = $::os_service_default,
){
  include ::mistral::params

  include ::mistral::db
  include ::mistral::logging

  validate_string($keystone_password)

  package { 'mistral-common':
    ensure => $package_ensure,
    name   => $::mistral::params::common_package_name,
    tag    => ['openstack', 'mistral-package'],
  }

  mistral_config {
    'DEFAULT/rpc_backend':                  value => $rpc_backend;
    'keystone_authtoken/auth_uri':          value => $auth_uri;
    'keystone_authtoken/identity_uri':      value => $identity_uri;
    'keystone_authtoken/admin_user':        value => $keystone_user;
    'keystone_authtoken/admin_password':    value => $keystone_password;
    'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
    'coordination/backend_url':             value => $coordination_backend_url;
    'coordination/heartbeat_interval':      value => $coordination_heartbeat_interval;
    'DEFAULT/control_exchange':             value => $control_exchange;
    'DEFAULT/report_interval':              value => $report_interval;
    'DEFAULT/service_down_time':            value => $service_down_time;
  }

  if $rpc_backend == 'rabbit' {

    if ! $rabbit_password {
      fail('Please specify a rabbit_password parameter.')
    }

    mistral_config {
      'oslo_messaging_rabbit/rabbit_password':              value => $rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_userid':                value => $rabbit_userid;
      'oslo_messaging_rabbit/rabbit_virtual_host':          value => $rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl':               value => $rabbit_use_ssl;
      'oslo_messaging_rabbit/kombu_ssl_version':            value => $kombu_ssl_version;
      'oslo_messaging_rabbit/kombu_ssl_ca_certs':           value => $kombu_ssl_ca_certs;
      'oslo_messaging_rabbit/kombu_ssl_certfile':           value => $kombu_ssl_certfile;
      'oslo_messaging_rabbit/kombu_ssl_keyfile':            value => $kombu_ssl_keyfile;
      'oslo_messaging_rabbit/kombu_reconnect_delay':        value => $kombu_reconnect_delay;
      'oslo_messaging_rabbit/heartbeat_timeout_threshold':  value => $rabbit_heartbeat_timeout_threshold;
      'oslo_messaging_rabbit/heartbeat_rate':               value => $rabbit_heartbeat_rate;
      'oslo_messaging_rabbit/amqp_durable_queues':          value => $amqp_durable_queues;
    }

    if $rabbit_hosts {
      mistral_config { 'oslo_messaging_rabbit/rabbit_hosts': value => join(any2array($rabbit_hosts), ',') }
      mistral_config { 'oslo_messaging_rabbit/rabbit_host':  ensure => absent }
      mistral_config { 'oslo_messaging_rabbit/rabbit_port':  ensure => absent }
    } else {
      mistral_config { 'oslo_messaging_rabbit/rabbit_host':  value => $rabbit_host }
      mistral_config { 'oslo_messaging_rabbit/rabbit_port':  value => $rabbit_port }
      mistral_config { 'oslo_messaging_rabbit/rabbit_hosts': value => "${rabbit_host}:${rabbit_port}" }
    }

    # By default rabbit_ha_queues is undef
    if $rabbit_ha_queues == undef {
      if size($rabbit_hosts) > 1 {
        mistral_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value  => true }
      } else {
        mistral_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
      }
    } else {
      mistral_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => $rabbit_ha_queues }
    }

  }
}
