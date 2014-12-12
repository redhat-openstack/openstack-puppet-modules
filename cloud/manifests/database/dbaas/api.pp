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
# == Class: cloud::database::dbaas::api
#
# Class to install API service of OpenStack Database as a Service (Trove)
#
# === Parameters:
#
# [*ks_trove_password*]
#   (required) Password used by trove for Keystone authentication.
#   Default: 'trovepassword'
#
# [*verbose*]
#   (optional) Rather to log the trove api service at verbose level.
#   Default: true
#
# [*debug*]
#   (optional) Rather to log the trove api service at debug level.
#   Default: true
#
# [*use_syslog*]
#   (optional) Use syslog for logging.
#   Defaults to true
#
# [*api_eth*]
#   (optional) Hostname or IP to bind Trove API.
#   Defaults to '127.0.0.1'
#
# [*ks_trove_public_port*]
#   (optional) TCP public port used to connect to Trove API.
#   Defaults to '8779'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_port*]
#   (optional) TCP internal port used to connect to Keystone API.
#   Defaults to '5000'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol used to connect to Keystone API.
#   Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::database::dbaas::api(
  $ks_trove_password          = 'trovepassword',
  $verbose                    = true,
  $debug                      = true,
  $use_syslog                 = true,
  $api_eth                    = '127.0.0.1',
  $ks_trove_public_port       = '8779',
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $firewall_settings          = {},
) {

  include 'cloud::database::dbaas'

  class { 'trove::api':
    verbose           => $verbose,
    debug             => $debug,
    use_syslog        => $use_syslog,
    bind_host         => $api_eth,
    bind_port         => $ks_trove_public_port,
    auth_url          => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    keystone_password => $ks_trove_password,
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow trove-api access':
      port   => $ks_trove_public_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-trove_api":
    listening_service => 'trove_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_trove_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
