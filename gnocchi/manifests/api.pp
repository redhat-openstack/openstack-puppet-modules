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
#   Defaults to undef
#
# [*debug*]
#   (optional) Rather to log the gnocchi api service at debug level.
#   Defaults to undef
#
# [*log_file*]
#   (optional) The path of file used for logging
#   If set to boolean false, it will not log to any file.
#   Defaults to undef
#
# [*use_syslog*]
#   (Optional) Use syslog for logging.
#   Defaults to undef
#
# [*use_stderr*]
#   (optional) Use stderr for logging
#   Defaults to undef
#
# [*log_facility*]
#   (Optional) Syslog facility to receive log lines.
#   Defaults to undef
#
# [*log_dir*]
#   (optional) directory to which gnocchi logs are sent.
#   If set to boolean false, it will not log to any directory.
#   Defaults to undef
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
  $verbose                      = undef,
  $debug                        = undef,
  $use_syslog                   = undef,
  $use_stderr                   = undef,
  $log_facility                 = undef,
  $log_dir                      = undef,
  $log_file                     = undef,
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

  require ::keystone::python
  include ::gnocchi::logging
  include ::gnocchi::params

  Gnocchi_config<||> ~> Exec['post-gnocchi_config']
  Gnocchi_config<||> ~> Service['gnocchi-api']

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
      'database/connection':   value => $::gnocchi::database_connection, secret => true;
      'database/idle_timeout': value => $::gnocchi::database_idle_timeoutl;
    }
  }

  # basic service config
  gnocchi_config {
    'keystone_authtoken/identity_uri':      value => $identity_uri;
    'keystone_authtoken/admin_user':        value => $keystone_user;
    'keystone_authtoken/admin_password':    value => $keystone_password, secret => true;
    'keystone_authtoken/admin_tenant_name': value => $keystone_tenant;
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
