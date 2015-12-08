# == Class: aodh::db
#
#  Configure the aodh database
#
# === Parameters
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to "sqlite:////var/lib/aodh/aodh.sqlite".
#
# [*database_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to 3600.
#
# [*database_max_retries*]
#   Maximum number of database connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to 10.
#
# [*database_retry_interval*]
#   Interval between retries of opening a database connection.
#   (Optional) Defaults to 10.
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to 1.
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to 10.
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to 20.
#
class aodh::db (
  $database_connection     = 'sqlite:////var/lib/aodh/aodh.sqlite',
  $database_idle_timeout   = 3600,
  $database_min_pool_size  = 1,
  $database_max_pool_size  = 10,
  $database_max_retries    = 10,
  $database_retry_interval = 10,
  $database_max_overflow   = 20,
) {

  include ::aodh::params

  $database_connection_real = pick($::aodh::database_connection, $database_connection)
  $database_idle_timeout_real = pick($::aodh::database_idle_timeout, $database_idle_timeout)
  $database_min_pool_size_real = pick($::aodh::database_min_pool_size, $database_min_pool_size)
  $database_max_pool_size_real = pick($::aodh::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::aodh::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::aodh::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::aodh::database_max_overflow, $database_max_overflow)

  validate_re($database_connection_real,
    '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  if $database_connection_real {
    case $database_connection_real {
      /^mysql:\/\//: {
        $backend_package = false
        require 'mysql::bindings'
        require 'mysql::bindings::python'
      }
      /^postgresql:\/\//: {
        $backend_package = false
        require 'postgresql::lib::python'
      }
      /^sqlite:\/\//: {
        $backend_package = $::aodh::params::sqlite_package_name
      }
      default: {
        fail('Unsupported backend configured')
      }
    }

    if $backend_package and !defined(Package[$backend_package]) {
      package {'aodh-backend-package':
        ensure => present,
        name   => $backend_package,
        tag    => 'openstack',
      }
    }

    aodh_config {
      'database/connection':     value => $database_connection_real, secret => true;
      'database/idle_timeout':   value => $database_idle_timeout_real;
      'database/min_pool_size':  value => $database_min_pool_size_real;
      'database/max_retries':    value => $database_max_retries_real;
      'database/retry_interval': value => $database_retry_interval_real;
      'database/max_pool_size':  value => $database_max_pool_size_real;
      'database/max_overflow':   value => $database_max_overflow_real;
    }
  }

}
