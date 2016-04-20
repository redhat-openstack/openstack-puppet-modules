# == Class: aodh
#
# Full description of class aodh here.
#
# === Parameters
#
# [*ensure_package*]
#   (optional) The state of aodh packages
#   Defaults to 'present'
#
#  [*alarm_history_time_to_live*]
#    (Optional) Number of seconds that alarm histories are kept in the database for
#    (<= 0 means forever)
#    Defaults to $::os_service_default
#
# [*rpc_backend*]
#   (optional) The rpc backend implementation to use, can be:
#     rabbit (for rabbitmq)
#     zmq (for zeromq)
#   Defaults to 'rabbit'
#
# [*rabbit_host*]
#   (optional) Location of rabbitmq installation.
#   Defaults to 'localhost'
#
# [*rabbit_hosts*]
#   (optional) List of clustered rabbit servers.
#   Defaults to undef
#
# [*rabbit_port*]
#   (optional) Port for rabbitmq instance.
#   Defaults to '5672'
#
# [*rabbit_password*]
#   (optional) Password used to connect to rabbitmq.
#   Defaults to 'guest'
#
# [*rabbit_userid*]
#   (optional) User used to connect to rabbitmq.
#   Defaults to 'guest'
#
# [*rabbit_virtual_host*]
#   (optional) The RabbitMQ virtual host.
#   Defaults to '/'
#
# [*rabbit_use_ssl*]
#   (optional) Connect over SSL for RabbitMQ
#   Defaults to false
#
# [*rabbit_ha_queues*]
#   (optional) Use HA queues in RabbitMQ.
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
#   Defaults to '1.0'
#
# [*amqp_durable_queues*]
#   (optional) Define queues as "durable" to rabbitmq.
#   Defaults to false
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false or the $::os_service_default, it will not log to
#   any directory.
#   Defaults to undef.
#
# [*state_path*]
#   (optional) Directory for storing state.
#   Defaults to '/var/lib/aodh'
#
# [*lock_path*]
#   (optional) Directory for lock files.
#   On RHEL will be '/var/lib/aodh/tmp' and on Debian '/var/lock/aodh'
#   Defaults to $::aodh::params::lock_path
#
# [*verbose*]
#   (optional) Set log output to verbose output.
#   Defaults to undef
#
# [*debug*]
#   (optional) Set log output to debug output.
#   Defaults to undef
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to undef
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to undef
#
# [*notification_driver*]
#   (optional) Driver or drivers to handle sending notifications.
#   Value can be a string or a list.
#   Defaults to undef
#
# [*notification_topics*]
#   (optional) AMQP topic used for OpenStack notifications
#   Defaults to 'notifications'
#
# [*database_connection*]
#   (optional) Connection url for the aodh database.
#   Defaults to undef.
#
# [*slave_connection*]
#   (optional) Connection url to connect to aodh slave database (read-only).
#   Defaults to undef.
#
# [*database_max_retries*]
#   (optional) Maximum database connection retries during startup.
#   Defaults to undef.
#
# [*database_idle_timeout*]
#   (optional) Timeout before idle database connections are reaped.
#   Defaults to undef.
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   Defaults to undef.
#
# [*database_min_pool_size*]
#   (optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to undef.
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to undef.
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to: undef.
#
# [*gnocchi_url*]
#   (optional) URL to Gnocchi.
#   Defaults to: $::os_service_default.
#
# DEPRECATED PARAMETERS
#
class aodh (
  $ensure_package                     = 'present',
  $alarm_history_time_to_live         = $::os_service_default,
  $rpc_backend                        = 'rabbit',
  $rabbit_host                        = 'localhost',
  $rabbit_hosts                       = undef,
  $rabbit_password                    = 'guest',
  $rabbit_port                        = '5672',
  $rabbit_userid                      = 'guest',
  $rabbit_virtual_host                = '/',
  $rabbit_use_ssl                     = false,
  $rabbit_heartbeat_timeout_threshold = 0,
  $rabbit_heartbeat_rate              = 2,
  $rabbit_ha_queues                   = undef,
  $kombu_ssl_ca_certs                 = $::os_service_default,
  $kombu_ssl_certfile                 = $::os_service_default,
  $kombu_ssl_keyfile                  = $::os_service_default,
  $kombu_ssl_version                  = $::os_service_default,
  $kombu_reconnect_delay              = '1.0',
  $amqp_durable_queues                = false,
  $verbose                            = undef,
  $debug                              = undef,
  $use_syslog                         = undef,
  $use_stderr                         = undef,
  $log_facility                       = undef,
  $log_dir                            = undef,
  $notification_driver                = undef,
  $notification_topics                = 'notifications',
  $database_connection                = undef,
  $slave_connection                   = undef,
  $database_idle_timeout              = undef,
  $database_min_pool_size             = undef,
  $database_max_pool_size             = undef,
  $database_max_retries               = undef,
  $database_retry_interval            = undef,
  $database_max_overflow              = undef,
  $gnocchi_url                        = $::os_service_default,
  # DEPRECATED PARAMETERS
) inherits aodh::params {

  include ::aodh::db
  include ::aodh::logging

  package { 'aodh':
    ensure => $ensure_package,
    name   => $::aodh::params::common_package_name,
    tag    => ['openstack', 'aodh-package'],
  }

  if $rpc_backend == 'rabbit' {
    oslo::messaging::rabbit { 'aodh_config':
      rabbit_userid               => $rabbit_userid,
      rabbit_password             => $rabbit_password,
      rabbit_virtual_host         => $rabbit_virtual_host,
      rabbit_host                 => $rabbit_host,
      rabbit_port                 => $rabbit_port,
      rabbit_hosts                => $rabbit_hosts,
      rabbit_ha_queues            => $rabbit_ha_queues,
      heartbeat_timeout_threshold => $rabbit_heartbeat_timeout_threshold,
      heartbeat_rate              => $rabbit_heartbeat_rate,
      rabbit_use_ssl              => $rabbit_use_ssl,
      kombu_reconnect_delay       => $kombu_reconnect_delay,
      kombu_ssl_version           => $kombu_ssl_version,
      kombu_ssl_keyfile           => $kombu_ssl_keyfile,
      kombu_ssl_certfile          => $kombu_ssl_certfile,
      kombu_ssl_ca_certs          => $kombu_ssl_ca_certs,
    }

    aodh_config {
      'DEFAULT/amqp_durable_queues': value => $amqp_durable_queues;
    }
  }

  oslo::messaging::notifications { 'aodh_config':
    driver => $notification_driver,
    topics => $notification_topics,
  }

  aodh_config {
    'DEFAULT/gnocchi_url':                 value => $gnocchi_url;
    'database/alarm_history_time_to_live': value => $alarm_history_time_to_live;
  }
}
