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
# == Class: cloud::volume::api
#
# Volume API node
#
# === Parameters:
#
# [*default_volume_type*]
#   (required) default volume type to use.
#   This should contain the name of the default volume type to use.
#   If not configured, it produces an error when creating a volume
#   without specifying a type.
#
# [*ks_cinder_internal_port*]
#   (optional) TCP port to connect to Cinder API from public network
#   Defaults to '8776'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance API
#   Defaults to '127.0.0.1'
#
# [*ks_cinder_password*]
#   (optional) Password used by Cinder to connect to Keystone API
#   Defaults to 'cinderpassword'
#
# [*ks_glance_api_internal_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Defaults to '9292'
#
# [*api_eth*]
#   (optional) Which interface we bind the Cinder API server.
#   Defaults to '127.0.0.1'
#
# [*ks_glance_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::volume::api(
  $default_volume_type,
  $ks_cinder_internal_port     = 8776,
  $ks_cinder_password          = 'cinderpassword',
  $ks_keystone_internal_host   = '127.0.0.1',
  $ks_keystone_internal_proto  = 'http',
  $ks_glance_internal_host     = '127.0.0.1',
  $ks_glance_api_internal_port = 9292,
  $api_eth                     = '127.0.0.1',
  $ks_glance_internal_proto    = 'http',
  $firewall_settings           = {},
) {

  include 'cloud::volume'

  if ! $default_volume_type {
    fail('default_volume_type should be defined when running Cinder Multi-Backend.')
  }

  class { 'cinder::api':
    keystone_password      => $ks_cinder_password,
    keystone_auth_host     => $ks_keystone_internal_host,
    keystone_auth_protocol => $ks_keystone_internal_proto,
    bind_host              => $api_eth,
    default_volume_type    => $default_volume_type
  }

  class { 'cinder::glance':
    glance_api_servers     => "${ks_glance_internal_proto}://${ks_glance_internal_host}:${ks_glance_api_internal_port}",
    glance_request_timeout => '10',
    glance_num_retries     => '10'
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow cinder-api access':
      port   => $ks_cinder_internal_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-cinder_api":
    listening_service => 'cinder_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_cinder_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
