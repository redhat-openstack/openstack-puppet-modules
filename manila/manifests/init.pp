# Class: manila
#
# == Parameters
#
# [*sql_connection*]
#    Url used to connect to database.
#    (Optional) Defaults to
#    'sqlite:////var/lib/manila/manila.sqlite'
#
# [*sql_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to 3600.
#
# [*control_exchange*]
#   (Optional) The default exchange under which topics are scope.
#   Defaults to 'openstack'.
#
# [*rpc_backend*]
#   (Optional) Use these options to configure the RabbitMQ message system.
#   Defaults to 'heat.openstack.common.rpc.impl_kombu'
#
# [*package_ensure*]
#    (Optional) Ensure state for package.
#    Defaults to 'present'
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
# [*qpid_sasl_mechanisms*]
#   (Optional) ENable one or more SASL mechanisms.
#   Defaults to false.
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
class manila (
  $sql_connection              = 'sqlite:////var/lib/manila/manila.sqlite',
  $sql_idle_timeout            = '3600',
  $rpc_backend                 = 'manila.openstack.common.rpc.impl_kombu',
  $control_exchange            = 'openstack',
  $rabbit_host                 = '127.0.0.1',
  $rabbit_port                 = 5672,
  $rabbit_hosts                = false,
  $rabbit_virtual_host         = '/',
  $rabbit_userid               = 'guest',
  $rabbit_password             = false,
  $rabbit_use_ssl              = false,
  $kombu_ssl_ca_certs          = undef,
  $kombu_ssl_certfile          = undef,
  $kombu_ssl_keyfile           = undef,
  $kombu_ssl_version           = 'TLSv1',
  $amqp_durable_queues         = false,
  $qpid_hostname               = 'localhost',
  $qpid_port                   = '5672',
  $qpid_username               = 'guest',
  $qpid_password               = false,
  $qpid_sasl_mechanisms        = false,
  $qpid_reconnect              = true,
  $qpid_reconnect_timeout      = 0,
  $qpid_reconnect_limit        = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval     = 0,
  $qpid_heartbeat              = 60,
  $qpid_protocol               = 'tcp',
  $qpid_tcp_nodelay            = true,
  $package_ensure              = 'present',
  $use_ssl                     = false,
  $ca_file                     = false,
  $cert_file                   = false,
  $key_file                    = false,
  $api_paste_config            = '/etc/manila/api-paste.ini',
  $use_syslog                  = false,
  $log_facility                = 'LOG_USER',
  $log_dir                     = '/var/log/manila',
  $verbose                     = false,
  $debug                       = false,
  $storage_availability_zone   = 'nova',
  $rootwrap_config             = '/etc/manila/rootwrap.conf',
  $lock_path                   = '/tmp/manila/manila_locks',
) {

  include ::manila::params

  Package['manila'] -> Manila_config<||>
  Package['manila'] -> Manila_api_paste_ini<||>

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
  }

  file { $::manila::params::manila_conf:
    ensure  => present,
    owner   => 'manila',
    group   => 'manila',
    mode    => '0600',
    require => Package['manila'],
  }

  file { $::manila::params::manila_paste_api_ini:
    ensure  => present,
    owner   => 'manila',
    group   => 'manila',
    mode    => '0600',
    require => Package['manila'],
  }

  if $rpc_backend == 'manila.openstack.common.rpc.impl_kombu' {

    if ! $rabbit_password {
      fail('Please specify a rabbit_password parameter.')
    }

    manila_config {
      'DEFAULT/rabbit_password':     value => $rabbit_password, secret => true;
      'DEFAULT/rabbit_userid':       value => $rabbit_userid;
      'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
      'DEFAULT/rabbit_use_ssl':      value => $rabbit_use_ssl;
      'DEFAULT/control_exchange':    value => $control_exchange;
      'DEFAULT/amqp_durable_queues': value => $amqp_durable_queues;
    }

    if $rabbit_hosts {
      manila_config { 'DEFAULT/rabbit_hosts':     value => join($rabbit_hosts, ',') }
      manila_config { 'DEFAULT/rabbit_ha_queues': value => true }
    } else {
      manila_config { 'DEFAULT/rabbit_host':      value => $rabbit_host }
      manila_config { 'DEFAULT/rabbit_port':      value => $rabbit_port }
      manila_config { 'DEFAULT/rabbit_hosts':     value => "${rabbit_host}:${rabbit_port}" }
      manila_config { 'DEFAULT/rabbit_ha_queues': value => false }
    }

    if $rabbit_use_ssl {

      if $kombu_ssl_ca_certs {
        manila_config { 'DEFAULT/kombu_ssl_ca_certs': value => $kombu_ssl_ca_certs; }
      } else {
        manila_config { 'DEFAULT/kombu_ssl_ca_certs': ensure => absent; }
      }

      if $kombu_ssl_certfile or $kombu_ssl_keyfile {
        manila_config {
          'DEFAULT/kombu_ssl_certfile': value => $kombu_ssl_certfile;
          'DEFAULT/kombu_ssl_keyfile':  value => $kombu_ssl_keyfile;
        }
      } else {
        manila_config {
          'DEFAULT/kombu_ssl_certfile': ensure => absent;
          'DEFAULT/kombu_ssl_keyfile':  ensure => absent;
        }
      }

      if $kombu_ssl_version {
        manila_config { 'DEFAULT/kombu_ssl_version':  value => $kombu_ssl_version; }
      } else {
        manila_config { 'DEFAULT/kombu_ssl_version':  ensure => absent; }
      }

    } else {
      manila_config {
        'DEFAULT/kombu_ssl_ca_certs': ensure => absent;
        'DEFAULT/kombu_ssl_certfile': ensure => absent;
        'DEFAULT/kombu_ssl_keyfile':  ensure => absent;
        'DEFAULT/kombu_ssl_version':  ensure => absent;
      }
    }

  }

  if $rpc_backend == 'manila.openstack.common.rpc.impl_qpid' {

    if ! $qpid_password {
      fail('Please specify a qpid_password parameter.')
    }

    manila_config {
      'DEFAULT/qpid_hostname':               value => $qpid_hostname;
      'DEFAULT/qpid_port':                   value => $qpid_port;
      'DEFAULT/qpid_username':               value => $qpid_username;
      'DEFAULT/qpid_password':               value => $qpid_password, secret => true;
      'DEFAULT/qpid_reconnect':              value => $qpid_reconnect;
      'DEFAULT/qpid_reconnect_timeout':      value => $qpid_reconnect_timeout;
      'DEFAULT/qpid_reconnect_limit':        value => $qpid_reconnect_limit;
      'DEFAULT/qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'DEFAULT/qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'DEFAULT/qpid_reconnect_interval':     value => $qpid_reconnect_interval;
      'DEFAULT/qpid_heartbeat':              value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol':               value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay':            value => $qpid_tcp_nodelay;
      'DEFAULT/amqp_durable_queues':         value => $amqp_durable_queues;
    }

    if is_array($qpid_sasl_mechanisms) {
      manila_config {
        'DEFAULT/qpid_sasl_mechanisms': value => join($qpid_sasl_mechanisms, ' ');
      }
    } elsif $qpid_sasl_mechanisms {
      manila_config {
        'DEFAULT/qpid_sasl_mechanisms': value => $qpid_sasl_mechanisms;
      }
    } else {
      manila_config {
        'DEFAULT/qpid_sasl_mechanisms': ensure => absent;
      }
    }
  }

  manila_config {
    'DEFAULT/sql_connection':            value => $sql_connection, secret => true;
    'DEFAULT/sql_idle_timeout':          value => $sql_idle_timeout;
    'DEFAULT/verbose':                   value => $verbose;
    'DEFAULT/debug':                     value => $debug;
    'DEFAULT/api_paste_config':          value => $api_paste_config;
    'DEFAULT/rpc_backend':               value => $rpc_backend;
    'DEFAULT/storage_availability_zone': value => $storage_availability_zone;
    'DEFAULT/rootwrap_config':           value => $rootwrap_config;
    'DEFAULT/lock_path':                 value => $lock_path;
  }

  if($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    require 'mysql::bindings'
    require 'mysql::bindings::python'
  } elsif($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

  } elsif($sql_connection =~ /sqlite:\/\//) {

  } else {
    fail("Invalid db connection ${sql_connection}")
  }

  if $log_dir {
    manila_config {
      'DEFAULT/log_dir': value => $log_dir;
    }
  } else {
    manila_config {
      'DEFAULT/log_dir': ensure => absent;
    }
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

  if $use_syslog {
    manila_config {
      'DEFAULT/use_syslog':           value => true;
      'DEFAULT/syslog_log_facility':  value => $log_facility;
    }
  } else {
    manila_config {
      'DEFAULT/use_syslog':           value => false;
    }
  }

}
