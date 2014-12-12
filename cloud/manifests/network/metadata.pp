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
# Network Metadata node (need to be run once)
# Could be managed by spof_node manifest
#
# === Parameters:
#
# [*enabled*]
#   (optional) State of the metadata service.
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*ks_neutron_password*]
#   (optional) Password used by Neutron to connect to Keystone API
#   Defaults to 'neutronpassword'
#
# [*neutron_metadata_proxy_shared_secret*]
#   (optional) Shared secret to validate proxies Neutron metadata requests
#   Defaults to 'metadatapassword'
#
# [*nova_metadata_server*]
#   (optional) Hostname or IP of the Nova metadata server
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Defaults to '35357'
#
# [*ks_nova_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*auth_region*]
#   (optional) OpenStack Region Name
#   Defaults to 'RegionOne'
#
class cloud::network::metadata(
  $enabled                              = true,
  $debug                                = true,
  $ks_neutron_password                  = 'neutronpassword',
  $neutron_metadata_proxy_shared_secret = 'asecreteaboutneutron',
  $nova_metadata_server                 = '127.0.0.1',
  $ks_keystone_admin_proto              = 'http',
  $ks_keystone_admin_port               = 35357,
  $ks_keystone_admin_host               = '127.0.0.1',
  $auth_region                          = 'RegionOne',
  $ks_nova_internal_proto               = 'http'
) {

  include 'cloud::network'
  include 'cloud::network::vswitch'

  class { 'neutron::agents::metadata':
    enabled          => $enabled,
    shared_secret    => $neutron_metadata_proxy_shared_secret,
    debug            => $debug,
    metadata_ip      => $nova_metadata_server,
    auth_url         => "${ks_keystone_admin_proto}://${ks_keystone_admin_host}:${ks_keystone_admin_port}/v2.0",
    auth_password    => $ks_neutron_password,
    auth_region      => $auth_region,
    metadata_workers => $::processorcount
  }

  neutron_metadata_agent_config {
    'DEFAULT/nova_metadata_protocol': value => $ks_nova_internal_proto;
  }

}
