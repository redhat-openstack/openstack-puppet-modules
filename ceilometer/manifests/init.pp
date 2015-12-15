# Class ceilometer
#
#  ceilometer base package & configuration
#
# == parameters
#
#  [*http_timeout*]
#    timeout seconds for HTTP requests
#     Defaults to 600
#  [*event_time_to_live*]
#    number of seconds that events are kept in the database for
#    (<= 0 means forever)
#    Defaults to -1
#  [*metering_time_to_live*]
#    number of seconds that samples are kept in the database for
#    (<= 0 means forever)
#    Defaults to -1
#  [*alarm_history_time_to_live*]
#    number of seconds that alarm histories are kept in the database for
#    (<= 0 means forever)
#    Defaults to -1
#  [*metering_secret*]
#    secret key for signing messages. Mandatory.
#  [*notification_topics*]
#    AMQP topic used for OpenStack notifications (list value)
#    Defaults to 'notifications'
#  [*package_ensure*]
#    ensure state for package. Optional. Defaults to 'present'
#  [*debug*]
#    should the daemons log debug messages. Optional. Defaults to undef
#  [*log_dir*]
#    (optional) directory to which ceilometer logs are sent.
#    If set to boolean false, it will not log to any directory.
#    Defaults to undef
#  [*verbose*]
#    should the daemons log verbose messages. Optional. Defaults to undef
#  [*use_syslog*]
#    (optional) Use syslog for logging
#    Defaults to undef
#  [*use_stderr*]
#    (optional) Use stderr for logging
#    Defaults to undef
#  [*log_facility*]
#    (optional) Syslog facility to receive log lines.
#    Defaults to undef
# [*rpc_backend*]
#    (optional) what rpc/queuing service to use
#    Defaults to 'rabbit'
#  [*rabbit_host*]
#    ip or hostname of the rabbit server. Optional. Defaults to '127.0.0.1'
#  [*rabbit_port*]
#    port of the rabbit server. Optional. Defaults to 5672.
#  [*rabbit_hosts*]
#    array of host:port (used with HA queues). Optional. Defaults to undef.
#    If defined, will remove rabbit_host & rabbit_port parameters from config
#  [*rabbit_userid*]
#    user to connect to the rabbit server. Optional. Defaults to 'guest'
#  [*rabbit_password*]
#    password to connect to the rabbit_server. Optional. Defaults to empty.
#  [*rabbit_virtual_host*]
#    virtualhost to use. Optional. Defaults to '/'
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
#  [*rabbit_use_ssl*]
#    (optional) Connect over SSL for RabbitMQ
#    Defaults to false
#  [*kombu_ssl_ca_certs*]
#    (optional) SSL certification authority file (valid only if SSL enabled).
#    Defaults to undef
#  [*kombu_ssl_certfile*]
#    (optional) SSL cert file (valid only if SSL enabled).
#    Defaults to undef
#  [*kombu_ssl_keyfile*]
#    (optional) SSL key file (valid only if SSL enabled).
#    Defaults to undef
#  [*kombu_ssl_version*]
#    (optional) SSL version to use (valid only if SSL enabled).
#    Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#    available on some distributions.
#    Defaults to 'TLSv1'
#  [*memcached_servers*]
#    (optional) A list of memcached server(s) to use for caching.
#    Defaults to undef
#
# DEPRECATED PARAMETERS
#
# [*qpid_hostname*]
# [*qpid_port*]
# [*qpid_username*]
# [*qpid_password*]
# [*qpid_heartbeat*]
# [*qpid_protocol*]
# [*qpid_tcp_nodelay*]
# [*qpid_reconnect*]
# [*qpid_reconnect_timeout*]
# [*qpid_reconnect_limit*]
# [*qpid_reconnect_interval*]
# [*qpid_reconnect_interval_min*]
# [*qpid_reconnect_interval_max*]
#
class ceilometer(
  $http_timeout                       = '600',
  $event_time_to_live                 = '-1',
  $metering_time_to_live              = '-1',
  $alarm_history_time_to_live         = '-1',
  $metering_secret                    = false,
  $notification_topics                = ['notifications'],
  $package_ensure                     = 'present',
  $debug                              = undef,
  $log_dir                            = undef,
  $verbose                            = undef,
  $use_syslog                         = undef,
  $use_stderr                         = undef,
  $log_facility                       = undef,
  $rpc_backend                        = 'rabbit',
  $rabbit_host                        = '127.0.0.1',
  $rabbit_port                        = 5672,
  $rabbit_hosts                       = undef,
  $rabbit_userid                      = 'guest',
  $rabbit_password                    = '',
  $rabbit_virtual_host                = '/',
  $rabbit_heartbeat_timeout_threshold = 0,
  $rabbit_heartbeat_rate              = 2,
  $rabbit_use_ssl                     = false,
  $kombu_ssl_ca_certs                 = undef,
  $kombu_ssl_certfile                 = undef,
  $kombu_ssl_keyfile                  = undef,
  $kombu_ssl_version                  = 'TLSv1',
  $memcached_servers                  = undef,
  # DEPRECATED PARAMETERS
  $qpid_hostname                      = undef,
  $qpid_port                          = undef,
  $qpid_username                      = undef,
  $qpid_password                      = undef,
  $qpid_heartbeat                     = undef,
  $qpid_protocol                      = undef,
  $qpid_tcp_nodelay                   = undef,
  $qpid_reconnect                     = undef,
  $qpid_reconnect_timeout             = undef,
  $qpid_reconnect_limit               = undef,
  $qpid_reconnect_interval_min        = undef,
  $qpid_reconnect_interval_max        = undef,
  $qpid_reconnect_interval            = undef,
) {

  validate_string($metering_secret)

  include ::ceilometer::logging
  include ::ceilometer::params

  if $kombu_ssl_ca_certs and !$rabbit_use_ssl {
    fail('The kombu_ssl_ca_certs parameter requires rabbit_use_ssl to be set to true')
  }
  if $kombu_ssl_certfile and !$rabbit_use_ssl {
    fail('The kombu_ssl_certfile parameter requires rabbit_use_ssl to be set to true')
  }
  if $kombu_ssl_keyfile and !$rabbit_use_ssl {
    fail('The kombu_ssl_keyfile parameter requires rabbit_use_ssl to be set to true')
  }
  if ($kombu_ssl_certfile and !$kombu_ssl_keyfile) or ($kombu_ssl_keyfile and !$kombu_ssl_certfile) {
    fail('The kombu_ssl_certfile and kombu_ssl_keyfile parameters must be used together')
  }

  group { 'ceilometer':
    name    => 'ceilometer',
    require => Package['ceilometer-common'],
  }

  user { 'ceilometer':
    name    => 'ceilometer',
    gid     => 'ceilometer',
    system  => true,
    require => Package['ceilometer-common'],
  }

  package { 'ceilometer-common':
    ensure => $package_ensure,
    name   => $::ceilometer::params::common_package_name,
    tag    => ['openstack', 'ceilometer-package'],
  }

  # we keep "ceilometer.openstack.common.rpc.impl_kombu" for backward compatibility
  if $rpc_backend == 'ceilometer.openstack.common.rpc.impl_kombu' or $rpc_backend == 'rabbit' {

    if $rabbit_hosts {
      ceilometer_config { 'oslo_messaging_rabbit/rabbit_host': ensure => absent }
      ceilometer_config { 'oslo_messaging_rabbit/rabbit_port': ensure => absent }
      ceilometer_config { 'oslo_messaging_rabbit/rabbit_hosts':
        value => join($rabbit_hosts, ',')
      }
      } else {
      ceilometer_config { 'oslo_messaging_rabbit/rabbit_host': value => $rabbit_host }
      ceilometer_config { 'oslo_messaging_rabbit/rabbit_port': value => $rabbit_port }
      ceilometer_config { 'oslo_messaging_rabbit/rabbit_hosts':
        value => "${rabbit_host}:${rabbit_port}"
      }
    }

      if size($rabbit_hosts) > 1 {
        ceilometer_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => true }
      } else {
        ceilometer_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
      }

      ceilometer_config {
        'oslo_messaging_rabbit/rabbit_userid':                value => $rabbit_userid;
        'oslo_messaging_rabbit/rabbit_password':              value => $rabbit_password, secret => true;
        'oslo_messaging_rabbit/rabbit_virtual_host':          value => $rabbit_virtual_host;
        'oslo_messaging_rabbit/rabbit_use_ssl':               value => $rabbit_use_ssl;
        'oslo_messaging_rabbit/heartbeat_timeout_threshold':  value => $rabbit_heartbeat_timeout_threshold;
        'oslo_messaging_rabbit/heartbeat_rate':               value => $rabbit_heartbeat_rate;
      }

      if $rabbit_use_ssl {

      if $kombu_ssl_ca_certs {
        ceilometer_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs; }
      } else {
        ceilometer_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $kombu_ssl_certfile or $kombu_ssl_keyfile {
        ceilometer_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': value => $kombu_ssl_certfile;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  value => $kombu_ssl_keyfile;
        }
      } else {
        ceilometer_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $kombu_ssl_version {
        ceilometer_config { 'oslo_messaging_rabbit/kombu_ssl_version':  value => $kombu_ssl_version; }
      } else {
        ceilometer_config { 'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent; }
      }

      } else {
        ceilometer_config {
          'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
        }
      }

  }

  # we keep "ceilometer.openstack.common.rpc.impl_qpid" for backward compatibility
  if $rpc_backend == 'ceilometer.openstack.common.rpc.impl_qpid' or $rpc_backend == 'qpid' {
    warning('Qpid driver is removed from Oslo.messaging in the Mitaka release')
  }

  # Once we got here, we can act as an honey badger on the rpc used.
  ceilometer_config {
    'DEFAULT/http_timeout'                : value => $http_timeout;
    'DEFAULT/rpc_backend'                 : value => $rpc_backend;
    'publisher/metering_secret'           : value => $metering_secret, secret => true;
    'DEFAULT/notification_topics'         : value => join($notification_topics, ',');
    'database/event_time_to_live'         : value => $event_time_to_live;
    'database/metering_time_to_live'      : value => $metering_time_to_live;
    'database/alarm_history_time_to_live' : value => $alarm_history_time_to_live;
  }

  if $memcached_servers {
    validate_array($memcached_servers)
  }

  if $memcached_servers {
    ceilometer_config {
      'DEFAULT/memcached_servers': value  => join($memcached_servers, ',')
    }
  } else {
    ceilometer_config {
      'DEFAULT/memcached_servers': ensure => absent;
    }
  }
}
