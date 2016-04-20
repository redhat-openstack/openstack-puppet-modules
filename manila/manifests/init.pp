# Class: manila
#
# == Parameters
#
# [*sql_connection*]
#    Url used to connect to database.
#    (Optional) Defaults to undef.
#
# [*sql_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to undef.
#
# [*database_retry_interval*]
#   (optional) Interval between retries of opening a database connection.
#   (Defaults to undef)
#
# [*database_min_pool_size*]
#   (optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to undef.
#
# [*database_max_pool_size*]
#   (optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to undef.
#
# [*database_max_retries*]
#   Maximum db connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to undef.
#
# [*database_max_overflow*]
#   (optional) If set, use this value for max_overflow with sqlalchemy.
#   Defaults to undef.
#
# [*state_path*]
#   (optional) Directory for storing state.
#   Defaults to '/var/lib/manila'
#
# [*control_exchange*]
#   (Optional) The default exchange under which topics are scope.
#   Defaults to 'openstack'.
#
# [*rpc_backend*]
#   (Optional) Use these options to configure the RabbitMQ message system.
#   Defaults to 'rabbit'
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
#
# [*notification_driver*]
#   (optional) Driver or drivers to handle sending notifications.
#   Defaults to 'messaging'
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
# [*rabbit_use_ssl*]
#   (Optional) Connect over SSL for RabbitMQ.
#   Defaults to false
#
# [*kombu_ssl_ca_certs*]
#   (optional) SSL certification authority file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_certfile*]
#   (optional) SSL cert file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_keyfile*]
#   (optional) SSL key file (valid only if SSL enabled).
#   Defaults to undef
#
# [*kombu_ssl_version*]
#   (optional) SSL version to use (valid only if SSL enabled).
#   Valid values are TLSv1, SSLv23 and SSLv3. SSLv2 may be
#   available on some distributions.
#   Defaults to 'TLSv1'
#
# [*amqp_durable_queues*]
#   Use durable queues in amqp.
#   (Optional) Defaults to false.
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef
#
# [*use_syslog*]
#   Use syslog for logging.
#   (Optional) Defaults to false.
#
# [*log_facility*]
#   Syslog facility to receive log lines.
#   (Optional) Defaults to LOG_USER.
#
# [*log_dir*]
#   (optional) Directory where logs should be stored.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/manila'
#
# [*use_ssl*]
#   (optional) Enable SSL on the API server
#   Defaults to false, not set
#
# [*cert_file*]
#   (optinal) Certificate file to use when starting API server securely
#   Defaults to false, not set
#
# [*key_file*]
#   (optional) Private key file to use when starting API server securely
#   Defaults to false, not set
#
# [*ca_file*]
#   (optional) CA certificate file to use to verify connecting clients
#   Defaults to false, not set_
#
# [*verbose*]
#   (Optional) Should the daemons log verbose messages
#   Defaults to false
#
# [*debug*]
#   (Optional) Should the daemons log debug messages
#   Defaults to false
#
# [*api_paste_config*]
#   (Optional) Allow Configuration of /etc/manila/api-paste.ini.
#
# [*storage_availability_zone*]
#   (optional) Availability zone of the node.
#   Defaults to 'nova'
#
# [*rootwrap_config*]
#   (optional) Path to the rootwrap configuration file to use for
#   running commands as root
#
# [*lock_path*]
#   (optional) Location to store Manila locks
#   Defaults to '/tmp/manila/manila_locks'
#
# [*amqp_server_request_prefix*]
#   address prefix used when sending to a specific server
#   Defaults to 'exclusive'
#
# [*amqp_broadcast_prefix*]
#   address prefix used when broadcasting to all servers
#   Defaults to 'broadcast'
#
# [*amqp_group_request_prefix*]
#   address prefix when sending to any server in group
#   Defaults to 'unicast'
#
# [*amqp_container_name*]
#   Name for the AMQP container
#   Defaults to guest
#
# [*amqp_idle_timeout*]
#   Timeout for inactive connections (in seconds)
#   Defaults to 0
#
# [*amqp_trace*]
#   Debug: dump AMQP frames to stdout
#   Defaults to false
#
# [*amqp_ssl_ca_file*]
#   (optional) CA certificate PEM file to verify server certificate
#   Defaults to undef
#
# [*amqp_ssl_cert_file*]
#   (optional) Identifying certificate PEM file to present to clients
#   Defaults to undef
#
# [*amqp_ssl_key_file*]
#   (optional) Private key PEM file used to sign cert_file certificate
#   Defaults to undef
#
# [*amqp_ssl_key_password*]
#   (optional) Password for decrypting ssl_key_file (if encrypted)
#   Defaults to undef
#
# [*amqp_allow_insecure_clients*]
#   (optional) Accept clients using either SSL or plain TCP
#   Defaults to false
#
class manila (
  $sql_connection              = undef,
  $sql_idle_timeout            = undef,
  $database_max_retries        = undef,
  $database_retry_interval     = undef,
  $database_min_pool_size      = undef,
  $database_max_pool_size      = undef,
  $database_max_overflow       = undef,
  $rpc_backend                 = 'rabbit',
  $control_exchange            = 'openstack',
  $notification_driver         = 'messaging',
  $rabbit_host                 = '127.0.0.1',
  $rabbit_port                 = 5672,
  $rabbit_hosts                = undef,
  $rabbit_virtual_host         = '/',
  $rabbit_userid               = 'guest',
  $rabbit_password             = false,
  $rabbit_ha_queues            = undef,
  $rabbit_use_ssl              = false,
  $kombu_ssl_ca_certs          = undef,
  $kombu_ssl_certfile          = undef,
  $kombu_ssl_keyfile           = undef,
  $kombu_ssl_version           = 'TLSv1',
  $amqp_durable_queues         = false,
  $package_ensure              = 'present',
  $use_ssl                     = false,
  $ca_file                     = false,
  $cert_file                   = false,
  $key_file                    = false,
  $api_paste_config            = '/etc/manila/api-paste.ini',
  $use_stderr                  = undef,
  $use_syslog                  = undef,
  $log_facility                = undef,
  $log_dir                     = undef,
  $verbose                     = undef,
  $debug                       = undef,
  $storage_availability_zone   = 'nova',
  $rootwrap_config             = '/etc/manila/rootwrap.conf',
  $state_path                  = '/var/lib/manila',
  $lock_path                   = '/tmp/manila/manila_locks',
  $amqp_server_request_prefix  = 'exclusive',
  $amqp_broadcast_prefix       = 'broadcast',
  $amqp_group_request_prefix   = 'unicast',
  $amqp_container_name         = 'guest',
  $amqp_idle_timeout           = '0',
  $amqp_trace                  = false,
  $amqp_allow_insecure_clients = false,
  $amqp_ssl_ca_file            = undef,
  $amqp_ssl_cert_file          = undef,
  $amqp_ssl_key_file           = undef,
  $amqp_ssl_key_password       = undef,
) {

  include ::manila::db
  include ::manila::logging
  include ::manila::params

  if $use_ssl {
    if !$cert_file {
      fail('The cert_file parameter is required when use_ssl is set to true')
    }
    if !$key_file {
      fail('The key_file parameter is required when use_ssl is set to true')
    }
  }

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

  # this anchor is used to simplify the graph between manila components by
  # allowing a resource to serve as a point where the configuration of manila begins
  anchor { 'manila-start': }

  package { 'manila':
    ensure  => $package_ensure,
    name    => $::manila::params::package_name,
    require => Anchor['manila-start'],
    tag     => ['openstack', 'manila-package'],
  }

  if $rpc_backend == 'manila.openstack.common.rpc.impl_kombu' or $rpc_backend == 'rabbit' {

    if ! $rabbit_password {
      fail('Please specify a rabbit_password parameter.')
    }

    manila_config {
      'oslo_messaging_rabbit/rabbit_password':     value => $rabbit_password, secret => true;
      'oslo_messaging_rabbit/rabbit_userid':       value => $rabbit_userid;
      'oslo_messaging_rabbit/rabbit_virtual_host': value => $rabbit_virtual_host;
      'oslo_messaging_rabbit/rabbit_use_ssl':      value => $rabbit_use_ssl;
      'DEFAULT/control_exchange':                  value => $control_exchange;
      'oslo_messaging_rabbit/amqp_durable_queues': value => $amqp_durable_queues;
    }

    if $rabbit_hosts {
      manila_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => join($rabbit_hosts, ',') }
    } else {
      manila_config { 'oslo_messaging_rabbit/rabbit_host':      value => $rabbit_host }
      manila_config { 'oslo_messaging_rabbit/rabbit_port':      value => $rabbit_port }
      manila_config { 'oslo_messaging_rabbit/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
    }

    if $rabbit_ha_queues == undef {
      if size($rabbit_hosts) > 1 {
        manila_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => true }
      } else {
        manila_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => false }
      }
    } else {
      manila_config { 'oslo_messaging_rabbit/rabbit_ha_queues': value => $rabbit_ha_queues }
    }

    if $rabbit_use_ssl {

      if $kombu_ssl_ca_certs {
        manila_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs; }
      } else {
        manila_config { 'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $kombu_ssl_certfile or $kombu_ssl_keyfile {
        manila_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': value => $kombu_ssl_certfile;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  value => $kombu_ssl_keyfile;
        }
      } else {
        manila_config {
          'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
          'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $kombu_ssl_version {
        manila_config { 'oslo_messaging_rabbit/kombu_ssl_version':  value => $kombu_ssl_version; }
      } else {
        manila_config { 'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      manila_config {
        'oslo_messaging_rabbit/kombu_ssl_ca_certs': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_certfile': ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_keyfile':  ensure => absent;
        'oslo_messaging_rabbit/kombu_ssl_version':  ensure => absent;
      }
    }

  }


  manila_config {
    'oslo_messaging_amqp/server_request_prefix':  value => $amqp_server_request_prefix;
    'oslo_messaging_amqp/broadcast_prefix':       value => $amqp_broadcast_prefix;
    'oslo_messaging_amqp/group_request_prefix':   value => $amqp_group_request_prefix;
    'oslo_messaging_amqp/container_name':         value => $amqp_container_name;
    'oslo_messaging_amqp/idle_timeout':           value => $amqp_idle_timeout;
    'oslo_messaging_amqp/trace':                  value => $amqp_trace;
    'oslo_messaging_amqp/allow_insecure_clients': value => $amqp_allow_insecure_clients,
  }


  if $amqp_ssl_ca_file {
    manila_config { 'oslo_messaging_amqp/ssl_ca_file': value => $amqp_ssl_ca_file; }
  } else {
    manila_config { 'oslo_messaging_amqp/ssl_ca_file': ensure => absent; }
  }

  if $amqp_ssl_key_password {
    manila_config { 'oslo_messaging_amqp/ssl_key_password': value => $amqp_ssl_key_password; }
  } else {
    manila_config { 'oslo_messaging_amqp/ssl_key_password': ensure => absent; }
  }

  if $amqp_ssl_cert_file {
    manila_config { 'oslo_messaging_amqp/ssl_cert_file': value => $amqp_ssl_cert_file; }
  } else {
    manila_config { 'oslo_messaging_amqp/ssl_cert_file': ensure => absent; }
  }

  if $amqp_ssl_key_file {
    manila_config { 'oslo_messaging_amqp/ssl_key_file': value => $amqp_ssl_key_file; }
  } else {
    manila_config { 'oslo_messaging_amqp/ssl_key_file': ensure => absent; }
  }


  manila_config {
    'DEFAULT/api_paste_config':          value => $api_paste_config;
    'DEFAULT/rpc_backend':               value => $rpc_backend;
    'DEFAULT/storage_availability_zone': value => $storage_availability_zone;
    'DEFAULT/rootwrap_config':           value => $rootwrap_config;
    'DEFAULT/notification_driver':       value => $notification_driver;
    'DEFAULT/state_path':                value => $state_path;
    'oslo_concurrency/lock_path':        value => $lock_path;
  }

  # SSL Options
  if $use_ssl {
    manila_config {
      'DEFAULT/ssl_cert_file' : value => $cert_file;
      'DEFAULT/ssl_key_file' :  value => $key_file;
    }
    if $ca_file {
      manila_config { 'DEFAULT/ssl_ca_file' :
        value => $ca_file,
      }
    } else {
      manila_config { 'DEFAULT/ssl_ca_file' :
        ensure => absent,
      }
    }
  } else {
    manila_config {
      'DEFAULT/ssl_cert_file' : ensure => absent;
      'DEFAULT/ssl_key_file' :  ensure => absent;
      'DEFAULT/ssl_ca_file' :   ensure => absent;
    }
  }

}
