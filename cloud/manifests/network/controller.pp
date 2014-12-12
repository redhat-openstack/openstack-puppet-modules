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
# Network Controller node (API + Scheduler)
#
# === Parameters:
#
# [*neutron_db_host*]
#   (optional) Host where user should be allowed all privileges for database.
#   Defaults to 127.0.0.1
#
# [*neutron_db_user*]
#   (optional) Name of neutron DB user.
#   Defaults to trove
#
# [*neutron_db_password*]
#   (optional) Password that will be used for the neutron db user.
#   Defaults to 'neutronpassword'
#
# [*ks_neutron_password*]
#   (optional) Password used by Neutron to connect to Keystone API
#   Defaults to 'neutronpassword'
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_public_port*]
#   (optional) TCP port to connect to Keystone API from public network
#   Defaults to '5000'
#
# [*ks_neutron_public_port*]
#   (optional) TCP port to connect to Neutron API from public network
#   Defaults to '9696'
#
# [*api_eth*]
#   (optional) Which interface we bind the Neutron server.
#   Defaults to '127.0.0.1'
#
# [*ks_admin_tenant*]
#   (optional) Admin tenant name in Keystone
#   Defaults to 'admin'
#
#
# [*nova_url*]
#   (optional) URL for connection to nova (Only supports one nova region
#   currently).
#   Defaults to 'http://127.0.0.1:8774/v2'
#
# [*nova_admin_auth_url*]
#   (optional) Authorization URL for connection to nova in admin context.
#   Defaults to 'http://127.0.0.1:5000/v2.0'
#
# [*nova_admin_username*]
#   (optional) Username for connection to nova in admin context
#   Defaults to 'nova'
#
# [*nova_admin_tenant_name*]
#   (optional) The name of the admin nova tenant
#   Defaults to 'services'
#
# [*nova_admin_password*]
#   (optional) Password for connection to nova in admin context.
#   Defaults to 'novapassword'
#
# [*nova_region_name*]
#   (optional) Name of nova region to use. Useful if keystone manages more than
#   one region.
#   Defaults to 'RegionOne'
#
# [*manage_ext_network*]
#   (optionnal) Manage or not external network with provider network API
#   Defaults to false.
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*tenant_network_types*]
#   (optional) Handled tenant network types
#   Defaults to ['gre']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#
# [*type_drivers*]
#   (optional) Drivers to load
#   Defaults to ['gre', 'vlan', 'flat']
#   Possible value ['local', 'flat', 'vlan', 'gre', 'vxlan']
#
# [*plugin*]
#   (optional) Neutron plugin name
#   Supported values: 'ml2', 'n1kv'.
#   Defaults to 'ml2'
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Defaults to '35357'
#
# [*provider_vlan_ranges*]
#   (optionnal) VLAN range for provider networks
#   Defaults to ['physnet1:1000:2999']
#
# [*flat_networks*]
#   (optionnal) List of physical_network names with which flat networks
#   can be created. Use * to allow flat networks with arbitrary
#   physical_network names.
#   Should be an array.
#   Default to ['public'].
#
# [*n1kv_vsm_ip*]
#   (required) N1KV VSM (Virtual Supervisor Module) VM's IP.
#   Defaults to 127.0.0.1
#
# [*n1kv_vsm_password*]
#   (required) N1KV VSM (Virtual Supervisor Module) password.
#   Defaults to secrete
#
# [*tunnel_id_ranges*]
#   (optional) GRE tunnel id ranges. used by he ml2 plugin
#   List of colon-separated id ranges
#   Defaults to ['1:10000']
#
# [*vni_ranges*]
#   (optional) VxLan Network ID range. used by the ml2 plugin
#   List of colon-separated id ranges
#   Defautls to ['1:10000']
#
class cloud::network::controller(
  $neutron_db_host         = '127.0.0.1',
  $neutron_db_user         = 'neutron',
  $neutron_db_password     = 'neutronpassword',
  $ks_neutron_password     = 'neutronpassword',
  $ks_keystone_admin_host  = '127.0.0.1',
  $ks_keystone_admin_proto = 'http',
  $ks_keystone_public_port = 5000,
  $ks_neutron_public_port  = 9696,
  $api_eth                 = '127.0.0.1',
  $ks_admin_tenant         = 'admin',
  $nova_url                = 'http://127.0.0.1:8774/v2',
  $nova_admin_auth_url     = 'http://127.0.0.1:5000/v2.0',
  $nova_admin_username     = 'nova',
  $nova_admin_tenant_name  = 'services',
  $nova_admin_password     = 'novapassword',
  $nova_region_name        = 'RegionOne',
  $manage_ext_network      = false,
  $firewall_settings       = {},
  $flat_networks              = ['public'],
  $tenant_network_types       = ['gre'],
  $type_drivers               = ['gre', 'vlan', 'flat'],
  $provider_vlan_ranges       = ['physnet1:1000:2999'],
  $plugin                     = 'ml2',
  # only needed by cisco n1kv plugin
  $n1kv_vsm_ip                = '127.0.0.1',
  $n1kv_vsm_password          = 'secrete',
  $ks_keystone_admin_port     = 35357,
  # only needed by ml2 plugin
  $tunnel_id_ranges           = ['1:10000'],
  $vni_ranges                 = ['1:10000'],
) {

  include 'cloud::network'

  $encoded_user = uriescape($neutron_db_user)
  $encoded_password = uriescape($neutron_db_password)

  class { 'neutron::server':
    auth_password       => $ks_neutron_password,
    auth_host           => $ks_keystone_admin_host,
    auth_protocol       => $ks_keystone_admin_proto,
    auth_port           => $ks_keystone_public_port,
    database_connection => "mysql://${encoded_user}:${encoded_password}@${neutron_db_host}/neutron?charset=utf8",
    mysql_module        => '2.2',
    api_workers         => $::processorcount,
    agent_down_time     => '60',
  }

  case $plugin {
    'ml2': {
      $core_plugin = 'neutron.plugins.ml2.plugin.Ml2Plugin'
      class { 'neutron::plugins::ml2':
        type_drivers          => $type_drivers,
        tenant_network_types  => $tenant_network_types,
        network_vlan_ranges   => $provider_vlan_ranges,
        tunnel_id_ranges      => $tunnel_id_ranges,
        vni_ranges            => $vni_ranges,
        flat_networks         => $flat_networks,
        mechanism_drivers     => ['linuxbridge', 'openvswitch','l2population'],
        enable_security_group => true
      }
    }

    'n1kv': {
      $core_plugin = 'neutron.plugins.cisco.network_plugin.PluginV2'
      class { 'neuton::plugins::cisco':
        database_user     => $neutron_db_user,
        database_password => $neutron_db_password,
        database_host     => $neutron_db_host,
        keystone_auth_url => "${ks_keystone_admin_proto}://${ks_keystone_admin_host}:${ks_keystone_admin_port}/v2.0/",
        keystone_password => $ks_neutron_password,
        vswitch_plugin    => 'neutron.plugins.cisco.n1kv.n1kv_neutron_plugin.N1kvNeutronPluginV2',
      }
      neutron_plugin_cisco {
        'securitygroup/firewall_driver': value => 'neutron.agent.firewall.NoopFirewallDriver';
        "N1KV:${n1kv_vsm_ip}/username":  value  => 'admin';
        "N1KV:${n1kv_vsm_ip}/password":  value  => $n1kv_vsm_password;
        # TODO (EmilienM) not sure about this one:
        'database/connection':           value => "mysql://${neutron_db_user}:${neutron_db_password}@${neutron_db_host}/neutron";
      }
    }

    default: {
      err "${plugin} plugin is not supported."
    }
  }

  class { 'neutron::server::notifications':
    nova_url               => $nova_url,
    nova_admin_auth_url    => $nova_admin_auth_url,
    nova_admin_username    => $nova_admin_username,
    nova_admin_tenant_name => $nova_admin_tenant_name,
    nova_admin_password    => $nova_admin_password,
    nova_region_name       => $nova_region_name
  }

  if $manage_ext_network {
    neutron_network {'public':
      provider_network_type     => 'flat',
      provider_physical_network => 'public',
      shared                    => true,
      router_external           => true
    }
  }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Neutron DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  Neutron_config<| |> ->
  exec {'neutron_db_sync':
    command => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
    path    => '/usr/bin',
    user    => 'neutron',
    unless  => "/usr/bin/mysql neutron -h ${neutron_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables",
    require => 'Neutron_config[DEFAULT/service_plugins]',
    notify  => Service['neutron-server']
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow neutron-server access':
      port   => $ks_neutron_public_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-neutron_api":
    listening_service => 'neutron_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_neutron_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
