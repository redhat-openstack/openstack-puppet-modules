#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: nova::db
#
#  Configures the Nova database.
#
# == Parameters
#
# [*database_connection*]
#   (optional) Connection url to connect to nova database.
#   Defaults to $::os_service_default
#
# [*slave_connection*]
#   (optional) Connection url to connect to nova slave database (read-only).
#   Defaults to $::os_service_default
#
# [*api_database_connection*]
#   (optional) Connection url to connect to nova api database.
#   Defaults to $::os_service_default
#
# [*api_slave_connection*]
#   (optional) Connection url to connect to nova api slave database (read-only).
#   Defaults to $::os_service_default
#
# [*database_idle_timeout*]
#   Timeout when db connections should be reaped.
#   (Optional) Defaults to $::os_service_default
#
# [*database_min_pool_size*]
#   Minimum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_pool_size*]
#   Maximum number of SQL connections to keep open in a pool.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_retries*]
#   Maximum db connection retries during startup.
#   Setting -1 implies an infinite retry count.
#   (Optional) Defaults to $::os_service_default
#
# [*database_retry_interval*]
#   Interval between retries of opening a sql connection.
#   (Optional) Defaults to $::os_service_default
#
# [*database_max_overflow*]
#   If set, use this value for max_overflow with sqlalchemy.
#   (Optional) Defaults to $::os_service_default
#
class nova::db (
  $database_connection     = $::os_service_default,
  $slave_connection        = $::os_service_default,
  $api_database_connection = $::os_service_default,
  $api_slave_connection    = $::os_service_default,
  $database_idle_timeout   = $::os_service_default,
  $database_min_pool_size  = $::os_service_default,
  $database_max_pool_size  = $::os_service_default,
  $database_max_retries    = $::os_service_default,
  $database_retry_interval = $::os_service_default,
  $database_max_overflow   = $::os_service_default,
) {

  include ::nova::deps
  include ::nova::params

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use nova::<myparam> first the nova::db::<myparam>
  $database_connection_real = pick($::nova::database_connection, $database_connection)
  $slave_connection_real = pick($::nova::slave_connection, $slave_connection)
  $api_database_connection_real = pick($::nova::api_database_connection, $api_database_connection)
  $api_slave_connection_real = pick($::nova::api_slave_connection, $api_slave_connection)
  $database_idle_timeout_real = pick($::nova::database_idle_timeout, $database_idle_timeout)
  $database_min_pool_size_real = pick($::nova::database_min_pool_size, $database_min_pool_size)
  $database_max_pool_size_real = pick($::nova::database_max_pool_size, $database_max_pool_size)
  $database_max_retries_real = pick($::nova::database_max_retries, $database_max_retries)
  $database_retry_interval_real = pick($::nova::database_retry_interval, $database_retry_interval)
  $database_max_overflow_real = pick($::nova::database_max_overflow, $database_max_overflow)

  if !is_service_default($database_connection_real) {

    validate_re($database_connection_real,
      '^(sqlite|mysql(\+pymysql)?|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

    case $database_connection_real {
      /^mysql(\+pymysql)?:\/\//: {
        require 'mysql::bindings'
        require 'mysql::bindings::python'
        if $database_connection_real =~ /^mysql\+pymysql/ {
          $backend_package = $::nova::params::pymysql_package_name
        } else {
          $backend_package = false
        }
      }
      /^postgresql:\/\//: {
        $backend_package = false
        require 'postgresql::lib::python'
      }
      /^sqlite:\/\//: {
        $backend_package = $::nova::params::sqlite_package_name
      }
      default: {
        fail('Unsupported backend configured')
      }
    }

    if $backend_package and !defined(Package[$backend_package]) {
      package {'nova-backend-package':
        ensure => present,
        name   => $backend_package,
        tag    => ['openstack', 'nova-package'],
      }
    }

    nova_config {
      'database/connection':       value => $database_connection_real, secret => true;
      'database/idle_timeout':     value => $database_idle_timeout_real;
      'database/min_pool_size':    value => $database_min_pool_size_real;
      'database/max_retries':      value => $database_max_retries_real;
      'database/retry_interval':   value => $database_retry_interval_real;
      'database/max_pool_size':    value => $database_max_pool_size_real;
      'database/max_overflow':     value => $database_max_overflow_real;
      'database/slave_connection': value => $slave_connection_real, secret => true;
    }

  }

  if !is_service_default($api_database_connection_real) {

    validate_re($api_database_connection_real,
      '^(sqlite|mysql(\+pymysql)?|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

    nova_config {
      'api_database/connection':       value => $api_database_connection_real, secret => true;
      'api_database/slave_connection': value => $api_slave_connection_real, secret => true;
    }

  }

}
