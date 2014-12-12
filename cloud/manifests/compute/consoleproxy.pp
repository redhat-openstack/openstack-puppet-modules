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
# == Class: cloud::compute::consoleproxy
#
# Compute Proxy Console node
#
# === Parameters:
#
# [*api_eth*]
#   (optional) Hostname or IP to bind Nova spicehtmlproxy service.
#   Defaults to '127.0.0.1'
#
# [*spice_port*]
#   (optional) TCP port to bind Nova spicehtmlproxy service.
#   Defaults to '6082'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::compute::consoleproxy(
  $api_eth           = '127.0.0.1',
  $spice_port        = '6082',
  $firewall_settings = {},
){

  include 'cloud::compute'

  class { 'nova::spicehtml5proxy':
    enabled => true,
    host    => $api_eth
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow spice access':
      port   => $spice_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-compute_spice":
    listening_service => 'spice_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $spice_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }
}
