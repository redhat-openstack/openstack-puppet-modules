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
# == Class: cloud::database::dbaas::conductor
#
# Class to install Conductor service of OpenStack Database as a Service (Trove)
#
# === Parameters:
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
class cloud::database::dbaas::conductor(
  $ks_keystone_internal_host  = '127.0.0.1',
  $ks_keystone_internal_port  = '5000',
  $ks_keystone_internal_proto = 'http',
  $verbose                    = true,
  $debug                      = true,
  $use_syslog                 = true,
) {

  include 'cloud::database::dbaas'

  class { 'trove::conductor':
    auth_url   => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}/v2.0",
    debug      => $debug,
    verbose    => $verbose,
    use_syslog => $use_syslog
  }

}
