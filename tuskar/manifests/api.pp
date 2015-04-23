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
# == Class tuskar::api
#
# Configure API service in tuskar
#
# == Parameters
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*package_ensure*]
#   (optional) Whether the tuskar api package will be installed
#   Defaults to 'present'
#
# [*keystone_password*]
#   (required) Password used to authentication.
#
# [*verbose*]
#   (optional) Rather to log the tuskar api service at verbose level.
#   Default: false
#
# [*debug*]
#   (optional) Rather to log the tuskar api service at debug level.
#   Default: false
#
# [*bind_host*]
#   (optional) The address of the host to bind to.
#   Default: 0.0.0.0
#
# [*bind_port*]
#   (optional) The port the server should bind to.
#   Default: 8585
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Default: /var/log/tuskar/tuskar-api.log
#
#  [*log_dir*]
#    (optional) directory to which tuskar logs are sent.
#    If set to boolean false, it will not log to any directory.
#    Defaults to '/var/log/tuskar'
#
# [*keystone_tenant*]
#   (optional) Tenant to authenticate to.
#   Defaults to services.
#
# [*keystone_user*]
#   (optional) User to authenticate as with keystone.
#   Defaults to 'tuskar'.

# [*enabled*]
#   (optional) Whether to enable services.
#   Defaults to true.
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to false.
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines.
#   Defaults to 'LOG_USER'.
#
# [*purge_config*]
#   (optional) Whether to set only the specified config options
#   in the api config.
#   Defaults to false.
#
# [*identity_uri*]
#   (optional) Complete admin Identity API endpoint.
#   Defaults to 'http://127.0.0.1:35357'.
#
class tuskar::api(
  $keystone_password,
  $verbose                      = false,
  $debug                        = false,
  $bind_host                    = '0.0.0.0',
  $bind_port                    = '8585',
  $log_file                     = '/var/log/tuskar/tuskar-api.log',
  $log_dir                      = '/var/log/tuskar',
  $keystone_tenant              = 'services',
  $keystone_user                = 'tuskar',
  $identity_uri                 = 'http://127.0.0.1:35357',
  $enabled                      = true,
  $use_syslog                   = false,
  $log_facility                 = 'LOG_USER',
  $purge_config                 = false,
  $manage_service               = true,
  $package_ensure               = 'present',
) inherits tuskar {

  require ::keystone::python
  include ::tuskar::params

  Tuskar_config<||> ~> Exec['post-tuskar_config']
  Tuskar_config<||> ~> Service['tuskar-api']
  Package['tuskar-api'] -> Tuskar_config<||>

  if $::tuskar::database_connection {
    if($::tuskar::database_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    } elsif($::tuskar::database_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

    } elsif($::tuskar::database_connection =~ /sqlite:\/\//) {

    } else {
      fail("Invalid db connection ${::tuskar::database_connection}")
    }
    tuskar_config {
      'database/sql_connection':   value => $::tuskar::database_connection, secret => true;
      'database/sql_idle_timeout': value => $::tuskar::database_idle_timeoutl;
    }
  }

  # basic service config
  tuskar_config {
    'DEFAULT/verbose':                      value => $verbose;
    'DEFAULT/debug':                        value => $debug;
    'DEFAULT/tuskar_api_bind_ip':           value => $bind_host;
    'DEFAULT/tuskar_api_port':              value => $bind_port;
    'keystone_authtoken/identity_uri':      value => $identity_uri;
    'keystone_authtoken/admin_user':        value => $keystone_user;
    'keystone_authtoken/admin_password':    value => $keystone_password, secret => true;
    'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
  }

  # Logging
  if $log_file {
    tuskar_config {
      'DEFAULT/log_file': value  => $log_file;
    }
  } else {
    tuskar_config {
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $log_dir {
    tuskar_config {
      'DEFAULT/log_dir': value  => $log_dir;
    }
  } else {
    tuskar_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # Syslog
  if $use_syslog {
    tuskar_config {
      'DEFAULT/use_syslog'          : value => true;
      'DEFAULT/syslog_log_facility' : value => $log_facility;
    }
  } else {
    tuskar_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  resources { 'tuskar_config':
    purge => $purge_config,
  }

  tuskar::generic_service { 'api':
    enabled        => $enabled,
    manage_service => $manage_service,
    package_ensure => $package_ensure,
    package_name   => $::tuskar::params::api_package_name,
    service_name   => $::tuskar::params::api_service_name,
  }
}
