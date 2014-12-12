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
# == Class: cloud::image::api
#
# Orchestration APIs node
#
# === Parameters:
#
# [*ks_heat_internal_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8004'
#
# [*ks_heat_cfn_internal_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8000'
#
# [*ks_heat_cloudwatch_internal_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8003'
#
# [*api_eth*]
#   (optional) Which interface we bind the Heat server.
#   Defaults to '127.0.0.1'
#
# [*workers*]
#   (optional) The number of Heat API workers
#   Defaults to $::processorcount
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::orchestration::api(
  $ks_heat_internal_port            = 8004,
  $ks_heat_cfn_internal_port        = 8000,
  $ks_heat_cloudwatch_internal_port = 8003,
  $api_eth                          = '127.0.0.1',
  $workers                          = $::processorcount,
  $firewall_settings                = {},
) {

  include 'cloud::orchestration'

  class { 'heat::api':
    bind_host => $api_eth,
    bind_port => $ks_heat_internal_port,
    workers   => $workers
  }

  class { 'heat::api_cfn':
    bind_host => $api_eth,
    bind_port => $ks_heat_cfn_internal_port,
    workers   => $workers
  }

  class { 'heat::api_cloudwatch':
    bind_host => $api_eth,
    bind_port => $ks_heat_cloudwatch_internal_port,
    workers   => $workers
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow heat-api access':
      port   => $ks_heat_internal_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow heat-cfn access':
      port   => $ks_heat_cfn_internal_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow heat-cloudwatch access':
      port   => $ks_heat_cloudwatch_internal_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-heat_api":
    listening_service => 'heat_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_heat_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-heat_cfn_api":
    listening_service => 'heat_cfn_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_heat_cfn_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-heat_cloudwatch_api":
    listening_service => 'heat_cloudwatch_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_heat_cloudwatch_internal_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
