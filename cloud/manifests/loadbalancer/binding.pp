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
define cloud::loadbalancer::binding (
  $ip,
  $port,
  $httpchk           = undef,
  $options           = undef,
  $bind_options      = undef,
  $firewall_settings = {},
){

  include cloud::loadbalancer

  # join all VIP together
  $vip_public_ip_array   = any2array($::cloud::loadbalancer::vip_public_ip)
  $vip_internal_ip_array = any2array($::cloud::loadbalancer::vip_internal_ip)
  if $::cloud::loadbalancer::vip_public_ip and $::cloud::loadbalancer::vip_internal_ip {
    $all_vip_array = union($vip_public_ip_array, $vip_internal_ip_array)
  }
  if $::cloud::loadbalancer::vip_public_ip and ! $::cloud::loadbalancer::vip_internal_ip {
    $all_vip_array = $vip_public_ip_array
  }
  if ! $::cloud::loadbalancer::vip_public_ip and $::cloud::loadbalancer::vip_internal_ip {
    $all_vip_array = $vip_internal_ip_array
  }
  if ! $::cloud::loadbalancer::vip_internal_ip and ! $::cloud::loadbalancer::vip_public_ip {
    fail('vip_public_ip and vip_internal_ip are both set to false, no binding is possible.')
  }

  # when we do not want binding
  if ($ip == false) {
    notice("no HAproxy binding for ${name} has been enabled.")
  } else {
    # when we want both internal & public binding
    if ($ip == true) {
      $listen_ip_real = $all_vip_array
    } else {
      # when binding is specified in parameter
      if (member($all_vip_array, $ip)) {
        $listen_ip_real = $ip
      } else {
        fail("${ip} is not part of VIP pools.")
      }
    }
    cloud::loadbalancer::listen_http { $name :
      ports        => $port,
      httpchk      => $httpchk,
      options      => $options,
      listen_ip    => $listen_ip_real,
      bind_options => $bind_options;
    }

    if $::cloud::manage_firewall {
      cloud::firewall::rule{ "100 allow ${name} binding access":
        port   => $port,
        extras => $firewall_settings,
      }
    }

  }

}
