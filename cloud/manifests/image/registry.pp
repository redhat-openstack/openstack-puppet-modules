#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
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
# == Class: cloud::image::registry
#
# Install Registry Image Server (Glance Registry)
#
# === Parameters:
#
# [*glance_db_host*]
#   (optional) Hostname or IP address to connect to glance database
#   Defaults to '127.0.0.1'
#
# [*glance_db_user*]
#   (optional) Username to connect to glance database
#   Defaults to 'glance'
#
# [*glance_db_password*]
#   (optional) Password to connect to glance database
#   Defaults to 'glancepassword'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance
#   Defaults to '127.0.0.1'
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance Registry from internal network
#   Defaults to '9191'
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Defaults to 'glancepassword'
#
# [*api_eth*]
#   (optional) Which interface we bind the Glance API server.
#   Defaults to '127.0.0.1'
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::image::registry(
  $glance_db_host                   = '127.0.0.1',
  $glance_db_user                   = 'glance',
  $glance_db_password               = 'glancepassword',
  $ks_keystone_internal_host        = '127.0.0.1',
  $ks_keystone_internal_proto       = 'http',
  $ks_glance_internal_host          = '127.0.0.1',
  $ks_glance_registry_internal_port = '9191',
  $ks_glance_password               = 'glancepassword',
  $api_eth                          = '127.0.0.1',
  $verbose                          = true,
  $debug                            = true,
  $log_facility                     = 'LOG_LOCAL0',
  $use_syslog                       = true,
  $firewall_settings                 = {},
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir           = false
    $log_file_api      = false
    $log_file_registry = false
    glance_registry_config {
      'DEFAULT/logging_context_format_string': value => '%(process)d: %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s';
      'DEFAULT/logging_default_format_string': value => '%(process)d: %(levelname)s %(name)s [-] %(instance)s%(message)s';
      'DEFAULT/logging_debug_format_suffix': value => '%(funcName)s %(pathname)s:%(lineno)d';
      'DEFAULT/logging_exception_prefix': value => '%(process)d: TRACE %(name)s %(instance)s';
    }
  } else {
    $log_dir           = '/var/log/glance'
    $log_file_api      = '/var/log/glance/api.log'
    $log_file_registry = '/var/log/glance/registry.log'
  }

  $encoded_glance_user     = uriescape($glance_db_user)
  $encoded_glance_password = uriescape($glance_db_password)

  class { 'glance::registry':
    database_connection => "mysql://${encoded_glance_user}:${encoded_glance_password}@${glance_db_host}/glance?charset=utf8",
    mysql_module        => '2.2',
    verbose             => $verbose,
    debug               => $debug,
    auth_host           => $ks_keystone_internal_host,
    auth_protocol       => $ks_keystone_internal_proto,
    keystone_password   => $ks_glance_password,
    keystone_tenant     => 'services',
    keystone_user       => 'glance',
    bind_host           => $api_eth,
    log_dir             => $log_dir,
    log_file            => $log_file_registry,
    bind_port           => $ks_glance_registry_internal_port,
    use_syslog          => $use_syslog,
    log_facility        => $log_facility,
  }

  exec {'glance_db_sync':
    command => 'glance-manage db_sync',
    user    => 'glance',
    path    => '/usr/bin',
    unless  => "/usr/bin/mysql glance -h ${glance_db_host} -u ${encoded_glance_user} -p${encoded_glance_password} -e \"show tables\" | /bin/grep Tables"
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow glance-registry access':
      port   => $ks_glance_registry_internal_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-glance_registry":
    listening_service => 'glance_registry_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_glance_registry_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
