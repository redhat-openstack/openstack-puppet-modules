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
# == Class: cloud::orchestration::engine
#
# Orchestration engine node (should be run once)
# Could be managed by spof node as Active / Passive.
#
# === Parameters:
#
# [*enabled*]
#   (optional) State of the orchestration engine service.
#   Defaults to true
#
# [*ks_heat_public_host*]
#   (optional) Public Hostname or IP to connect to Heat API
#   Defaults to '127.0.0.1'
#
# [*ks_heat_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_heat_password*]
#   (optional) Password used by Heat to connect to Keystone API
#   Defaults to 'heatpassword'
#
# [*ks_heat_cfn_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8000'
#
# [*ks_heat_cloudwatch_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8003'
#
#  [*auth_encryption_key*]
#    (optional) Encryption key used for authentication info in database
#    Defaults to 'secrete'
#
class cloud::orchestration::engine(
  $enabled                        = true,
  $ks_heat_public_host            = '127.0.0.1',
  $ks_heat_public_proto           = 'http',
  $ks_heat_password               = 'heatpassword',
  $ks_heat_cfn_public_port        = 8000,
  $ks_heat_cloudwatch_public_port = 8003,
  $auth_encryption_key            = 'secrete'
) {

  include 'cloud::orchestration'

  class { 'heat::engine':
    enabled                       => $enabled,
    auth_encryption_key           => $auth_encryption_key,
    heat_metadata_server_url      => "${ks_heat_public_proto}://${ks_heat_public_host}:${ks_heat_cfn_public_port}",
    heat_waitcondition_server_url => "${ks_heat_public_proto}://${ks_heat_public_host}:${ks_heat_cfn_public_port}/v1/waitcondition",
    heat_watch_server_url         => "${ks_heat_public_proto}://${ks_heat_public_host}:${ks_heat_cloudwatch_public_port}",
    # TODO (EmilienM): Need to be updated in Juno
    # The default deferred_auth_method of password is deprecated as of Icehouse, so although it is still the default, deployers are
    # strongly encouraged to move to using deferred_auth_method=trusts, which is planned to become the default for Juno.
    # 'trusts' requires Keystone API v3 enabled, otherwise we have to use 'password'.
    deferred_auth_method          => 'password',
  }

}
