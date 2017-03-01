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
# == Class gnocchi::api
#
# Configure API service in gnocchi
#
# == Parameters
#
# [*manage_service*]
#   (optional) Whether to start/stop the service
#   Defaults to true
#
# [*ensure_package*]
#   (optional) Whether the gnocchi api package will be installed
#   Defaults to 'present'
#
# [*keystone_password*]
#   (required) Password used to authentication.
#
# [*verbose*]
#   (optional) Rather to log the gnocchi api service at verbose level.
#   Default: false
#
# [*debug*]
#   (optional) Rather to log the gnocchi api service at debug level.
#   Default: false
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Default: /var/log/gnocchi/gnocchi-api.log
#
#  [*log_dir*]
#   (optional) directory to which gnocchi logs are sent.
#   If set to boolean false, it will not log to any directory.
#   Defaults to '/var/log/gnocchi'
#
# [*keystone_tenant*]
#   (optional) Tenant to authenticate to.
#   Defaults to services.
#
# [*keystone_user*]
#   (optional) User to authenticate as with keystone.
#   Defaults to 'gnocchi'.

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
class gnocchi::api(
  $keystone_password,
  $verbose                      = false,
  $debug                        = false,
  $log_file                     = '/var/log/gnocchi/gnocchi-api.log',
  $log_dir                      = '/var/log/gnocchi',
  $keystone_tenant              = 'services',
  $keystone_user                = 'gnocchi',
  $identity_uri                 = 'http://127.0.0.1:35357',
  $enabled                      = true,
  $use_syslog                   = false,
  $log_facility                 = 'LOG_USER',
  $purge_config                 = false,
  $manage_service               = true,
  $ensure_package               = 'present',
) inherits gnocchi {

  require keystone::python
  include gnocchi::params

  Gnocchi_config<||> ~> Exec['post-gnocchi_config']
  Gnocchi_config<||> ~> Service['gnocchi-api']
  Package['gnocchi-api'] -> Gnocchi_config<||>

  if $::gnocchi::database_connection {
    if($::gnocchi::database_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
      require 'mysql::bindings'
      require 'mysql::bindings::python'
    } elsif($::gnocchi::database_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {

    } elsif($::gnocchi::database_connection =~ /sqlite:\/\//) {

    } else {
      fail("Invalid db connection ${::gnocchi::database_connection}")
    }
    gnocchi_config {
      'database/sql_connection':   value => $::gnocchi::database_connection, secret => true;
      'database/sql_idle_timeout': value => $::gnocchi::database_idle_timeoutl;
    }
  }

  # basic service config
  gnocchi_config {
    'DEFAULT/verbose':                      value => $verbose;
    'DEFAULT/debug':                        value => $debug;
    'keystone_authtoken/identity_uri':      value => $identity_uri;
    'keystone_authtoken/admin_user':        value => $keystone_user;
    'keystone_authtoken/admin_password':    value => $keystone_password, secret => true;
    'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
  }

  # Logging
  if $log_file {
    gnocchi_config {
      'DEFAULT/log_file': value  => $log_file;
    }
  } else {
    gnocchi_config {
      'DEFAULT/log_file': ensure => absent;
    }
  }

  if $log_dir {
    gnocchi_config {
      'DEFAULT/log_dir': value  => $log_dir;
    }
  } else {
    gnocchi_config {
      'DEFAULT/log_dir': ensure => absent;
    }
  }

  # Syslog
  if $use_syslog {
    gnocchi_config {
      'DEFAULT/use_syslog'          : value => true;
      'DEFAULT/syslog_log_facility' : value => $log_facility;
    }
  } else {
    gnocchi_config {
      'DEFAULT/use_syslog': value => false;
    }
  }

  resources { 'gnocchi_config':
    purge => $purge_config,
  }

  gnocchi::generic_service { 'api':
    enabled        => $enabled,
    manage_service => $manage_service,
    ensure_package => $ensure_package,
    package_name   => $::gnocchi::params::api_package_name,
    service_name   => $::gnocchi::params::api_service_name,
  }
}
