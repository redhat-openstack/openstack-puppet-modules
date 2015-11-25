# == Class: heat
#
#  Heat base package & configuration
#
# === Parameters
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to undef.
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to undef.
#
# [*log_dir*]
#   (Optional) Directory where logs should be stored
#   If set to boolean 'false', it will not log to any directory
#   Defaults to undef.
#
# [*rpc_backend*]
#   (Optional) Use these options to configure the message system.
#   Defaults to 'rabbit'
#
# [*rpc_response_timeout*]
#   (Optional) Configure the timeout (in seconds) for rpc responses
#   Defaults to 60 seconds
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
#   (Optional) Password to connect to the rabbit_server.
#   Defaults to empty.
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
#   (Optional) Connect over SSL for RabbitMQ.
#   Defaults to false
#
# [*kombu_ssl_ca_certs*]
#   (Optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_certfile*]
#   (Optional) SSL cert file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_keyfile*]
#   (Optional) SSL key file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_version*]
#   (Optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to 'TLSv1'
#
# [*amqp_durable_queues*]
#   (Optional) Use durable queues in amqp.
#   Defaults to false
#
# == keystone authentication options
#
# [*auth_uri*]
#   (Optional) Specifies the public Identity URI for Heat to use.
#   Located in heat.conf.
#   Defaults to: false
#
# [*identity_uri*]
#   (Optional) Specifies the admin Identity URI for Heat to use.
#   Located in heat.conf.
#   Defaults to: false
#
# [*keystone_user*]
#
# [*keystone_tenant*]
#
# [*keystone_password*]
#
# [*keystone_ec2_uri*]
#
# ==== Various QPID options (Optional)
#
# [*qpid_hostname*]
#
# [*qpid_port*]
#
# [*qpid_username*]
#
# [*qpid_password*]
#
# [*qpid_heartbeat*]
#
# [*qpid_protocol*]
#
# [*qpid_tcp_nodelay*]
#
# [*qpid_reconnect*]
#
# [*qpid_reconnect_timeout*]
#
# [*qpid_reconnect_limit*]
#
# [*qpid_reconnect_interval*]
#
# [*qpid_reconnect_interval_min*]
#
# [*qpid_reconnect_interval_max*]
#
# [*database_connection*]
#   (optional) Connection url for the heat database.
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
# [*flavor*]
#   (optional) Specifies the Authentication method.
#   Set to 'standalone' to get Heat to work with a remote OpenStack
#   Tested versions include 0.9 and 2.2
#   Defaults to undef
#
# [*region_name*]
#   (Optional) Region name for services. This is the
#   default region name that heat talks to service endpoints on.
#   Defaults to undef
#
# [*instance_user*]
#   (Optional) The default user for new instances. Although heat claims that
#   this feature is deprecated, it still sets the users to ec2-user if
#   you leave this unset. If you want heat to not set instance_user to
#   ec2-user, you need to set this to an empty string. This feature has been
#   deprecated for some time and will likely be removed in L or M.
#
# [*enable_stack_adopt*]
#   (Optional) Enable the stack-adopt feature.
#   Defaults to undef
#
# [*enable_stack_abandon*]
#   (Optional) Enable the stack-abandon feature.
#   Defaults to undef
#
# [*sync_db*]
#   (Optional) Run db sync on nodes after connection setting has been set.
#   Defaults to true
#
# === Deprecated Parameters
#
# [*mysql_module*]
#   Deprecated. Does nothing.
#
# [*sql_connection*]
#   Deprecated. Use database_connection instead.
#
# [*keystone_host*]
#   (Optional) DEPRECATED The keystone host.
#   Defaults to localhost.
#
# [*keystone_port*]
#   (Optional) DEPRECATED The port used to access the keystone host.
#   Defaults to 35357.
#
# [*keystone_protocol*]
#   (Optional) DEPRECATED. The protocol used to access the keystone host
#   Defaults to http.
#
class heat(
  $auth_uri                           = false,
  $identity_uri                       = false,
  $package_ensure                     = 'present',
  $verbose                            = undef,
  $debug                              = undef,
  $log_dir                            = undef,
  $keystone_user                      = 'heat',
  $keystone_tenant                    = 'services',
  $keystone_password                  = false,
  $keystone_ec2_uri                   = 'http://127.0.0.1:5000/v2.0/ec2tokens',
  $rpc_backend                        = 'rabbit',
  $rpc_response_timeout               = 60,
  $rabbit_host                        = '127.0.0.1',
  $rabbit_port                        = 5672,
  $rabbit_hosts                       = undef,
  $rabbit_userid                      = 'guest',
  $rabbit_password                    = '',
  $rabbit_virtual_host                = '/',
  $rabbit_ha_queues                   = undef,
  $rabbit_heartbeat_timeout_threshold = 0,
  $rabbit_heartbeat_rate              = 2,
  $rabbit_use_ssl                     = false,
  $kombu_ssl_ca_certs                 = undef,
  $kombu_ssl_certfile                 = undef,
  $kombu_ssl_keyfile                  = undef,
  $kombu_ssl_version                  = 'TLSv1',
  $amqp_durable_queues                = false,
  $qpid_hostname                      = 'localhost',
  $qpid_port                          = 5672,
  $qpid_username                      = 'guest',
  $qpid_password                      = 'guest',
  $qpid_heartbeat                     = 60,
  $qpid_protocol                      = 'tcp',
  $qpid_tcp_nodelay                   = true,
  $qpid_reconnect                     = true,
  $qpid_reconnect_timeout             = 0,
  $qpid_reconnect_limit               = 0,
  $qpid_reconnect_interval_min        = 0,
  $qpid_reconnect_interval_max        = 0,
  $qpid_reconnect_interval            = 0,
  $use_syslog                         = undef,
  $use_stderr                         = undef,
  $log_facility                       = undef,
  $database_connection                = undef,
  $database_max_retries               = undef,
  $database_idle_timeout              = undef,
  $database_retry_interval            = undef,
  $database_min_pool_size             = undef,
  $database_max_pool_size             = undef,
  $database_max_overflow              = undef,
  $flavor                             = undef,
  $region_name                        = undef,
  $enable_stack_adopt                 = undef,
  $enable_stack_abandon               = undef,
  $sync_db                            = undef,
  # Deprecated parameters
  $mysql_module                       = undef,
  $sql_connection                     = undef,
  $keystone_host                      = '127.0.0.1',
  $keystone_port                      = '35357',
  $keystone_protocol                  = 'http',
  $instance_user                      = undef,
) {

  include ::heat::logging
  include ::heat::db
  include ::heat::deps
  include ::heat::params

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
  if $mysql_module {
    warning('The mysql_module parameter is deprecated. The latest 2.x mysql module will be used.')
  }

  package { 'heat-common':
    ensure => $package_ensure,
    name   => $::heat::params::common_package_name,
    tag    => ['openstack', 'heat-package'],
  }

  if $rpc_backend == 'rabbit' {

    if $rabbit_hosts {
      heat_config { 'oslo_messaging_rabbit/rabbit_host': ensure => absent }
      heat_config { 'oslo_messaging_rabbit/rabbit_port': ensure => absent }
      heat_config { 'oslo_messaging_rabbit/rabbit_hosts':
        value => join($rabbit_hosts, ',')
      }
    } else {
      heat_config { 'oslo_messaging_rabbit/rabbit_host': value => $rabbit_host }
      heat_config { 'oslo_messaging_rabbit/rabbit_port': value => $rabbit_port }
      heat_config { 'oslo_messaging_rabbit/rabbit_hosts':
        value => "${rabbit_host}:${rabbit_port}"
      }
    }

    if $rabbit_ha_queues == undef {
      if size($rabbit_hosts) > 1 {
        heat_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => true }
      } else {
        heat_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
      }
    } else {
      heat_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => $rabbit_ha_queues }
    }

    heat_config {
      'oslo_messaging_rabbit/rabbit_userid':                value => $rabbit_userid;
      'oslo_messaging_rabbit/rabbit_password':              value => $rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_virtual_host':          value => $rabbit_virtual_host;
      'oslo_messaging_rabbit/heartbeat_timeout_threshold':  value => $rabbit_heartbeat_timeout_threshold;
      'oslo_messaging_rabbit/heartbeat_rate':               value => $rabbit_heartbeat_rate;
      'oslo_messaging_rabbit/rabbit_use_ssl':               value => $rabbit_use_ssl;
      'oslo_messaging_rabbit/amqp_durable_queues':          value => $amqp_durable_queues;
    }

    if $rabbit_use_ssl {

      if $kombu_ssl_ca_certs {
        heat_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs; }
      } else {
        heat_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $kombu_ssl_certfile or $kombu_ssl_keyfile {
        heat_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': value => $kombu_ssl_certfile;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  value => $kombu_ssl_keyfile;
        }
      } else {
        heat_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $kombu_ssl_version {
        heat_config { 'oslo_messaging_rabbit/kombu_ssl_version':  value => $kombu_ssl_version; }
      } else {
        heat_config { 'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      heat_config {
        'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
      }
    }

  }

  if $rpc_backend == 'qpid' {

    heat_config {
      'oslo_messaging_qpid/qpid_hostname'               : value => $qpid_hostname;
      'oslo_messaging_qpid/qpid_port'                   : value => $qpid_port;
      'oslo_messaging_qpid/qpid_username'               : value => $qpid_username;
      'oslo_messaging_qpid/qpid_password'               : value => $qpid_password, secret => true;
      'oslo_messaging_qpid/qpid_heartbeat'              : value => $qpid_heartbeat;
      'oslo_messaging_qpid/qpid_protocol'               : value => $qpid_protocol;
      'oslo_messaging_qpid/qpid_tcp_nodelay'            : value => $qpid_tcp_nodelay;
      'oslo_messaging_qpid/qpid_reconnect'              : value => $qpid_reconnect;
      'oslo_messaging_qpid/qpid_reconnect_timeout'      : value => $qpid_reconnect_timeout;
      'oslo_messaging_qpid/qpid_reconnect_limit'        : value => $qpid_reconnect_limit;
      'oslo_messaging_qpid/qpid_reconnect_interval_min' : value => $qpid_reconnect_interval_min;
      'oslo_messaging_qpid/qpid_reconnect_interval_max' : value => $qpid_reconnect_interval_max;
      'oslo_messaging_qpid/qpid_reconnect_interval'     : value => $qpid_reconnect_interval;
      'oslo_messaging_qpid/amqp_durable_queues'         : value => $amqp_durable_queues;
    }

  }

  # if both auth_uri and identity_uri are set we skip these deprecated settings entirely
  if !$auth_uri or !$identity_uri {
    if $keystone_host {
      warning('The keystone_host parameter is deprecated. Please use auth_uri and identity_uri instead.')
      heat_config {
        'keystone_authtoken/auth_host': value => $keystone_host;
      }
    } else {
      heat_config {
        'keystone_authtoken/auth_host': ensure => absent;
      }
    }

    if $keystone_port {
      warning('The keystone_port parameter is deprecated. Please use auth_uri and identity_uri instead.')
      heat_config {
        'keystone_authtoken/auth_port': value => $keystone_port;
      }
    } else {
      heat_config {
        'keystone_authtoken/auth_port': ensure => absent;
      }
    }

    if $keystone_protocol {
      warning('The keystone_protocol parameter is deprecated. Please use auth_uri and identity_uri instead.')
      heat_config {
        'keystone_authtoken/auth_protocol': value => $keystone_protocol;
      }
    } else {
      heat_config {
        'keystone_authtoken/auth_protocol': ensure => absent;
      }
    }
  } else {
    heat_config {
      'keystone_authtoken/auth_host': ensure => absent;
      'keystone_authtoken/auth_port': ensure => absent;
      'keystone_authtoken/auth_protocol': ensure => absent;
    }
  }

  if $auth_uri {
    heat_config { 'keystone_authtoken/auth_uri': value => $auth_uri; }
  } else {
    heat_config { 'keystone_authtoken/auth_uri': value => "${keystone_protocol}://${keystone_host}:5000/v2.0"; }
  }

  if $identity_uri {
    heat_config {
      'keystone_authtoken/identity_uri': value => $identity_uri;
    }
  } else {
    heat_config {
      'keystone_authtoken/identity_uri': ensure => absent;
    }
  }

  heat_config {
    'DEFAULT/rpc_backend'                  : value => $rpc_backend;
    'DEFAULT/rpc_response_timeout'         : value => $rpc_response_timeout;
    'ec2authtoken/auth_uri'                : value => $keystone_ec2_uri;
    'keystone_authtoken/admin_tenant_name' : value => $keystone_tenant;
    'keystone_authtoken/admin_user'        : value => $keystone_user;
    'keystone_authtoken/admin_password'    : value => $keystone_password, secret => true;
  }

  if $flavor {
    heat_config { 'paste_deploy/flavor': value => $flavor; }
  } else {
    heat_config { 'paste_deploy/flavor': ensure => absent; }
  }

  # region name
  if $region_name {
    heat_config { 'DEFAULT/region_name_for_services': value => $region_name; }
  } else {
    heat_config { 'DEFAULT/region_name_for_services': ensure => absent; }
  }

  # instance_user
  # special case for empty string since it's a valid value
  if $instance_user == '' {
    heat_config { 'DEFAULT/instance_user': value => ''; }
  } elsif $instance_user {
    heat_config { 'DEFAULT/instance_user': value => $instance_user; }
  } else {
    heat_config { 'DEFAULT/instance_user': ensure => absent; }
  }

  if $enable_stack_adopt != undef {
    validate_bool($enable_stack_adopt)
    heat_config { 'DEFAULT/enable_stack_adopt': value => $enable_stack_adopt; }
  } else {
    heat_config { 'DEFAULT/enable_stack_adopt': ensure => absent; }
  }

  if $enable_stack_abandon != undef {
    validate_bool($enable_stack_abandon)
    heat_config { 'DEFAULT/enable_stack_abandon': value => $enable_stack_abandon; }
  } else {
    heat_config { 'DEFAULT/enable_stack_abandon': ensure => absent; }
  }
}
