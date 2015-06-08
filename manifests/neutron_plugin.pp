# == Class: midonet::neutron_plugin
#
# Install and configure Midonet Neutron Plugin. Please note that manifest does
# install Neutron (because it is a requirement of
# 'python-neutron-plugin-midonet' package) but it does not configure it nor run
# it. It just configure the specific midonet plugin files. It is supposed to be
# deployed along any existing puppet module  that configures Neutron, such as
# puppetlabs/neutron
#
# === Parameters
#
# [*midonet_api_ip*]
#   IP address of the midonet api service
# [*midonet_api_port*]
#   port address of the midonet api service
# [*keystone_username*]
#   Username from which midonet api will authenticate against Keystone (use
#   neutron service username)
# [*keystone_password*]
#   Password from which midonet api will authenticate against Keystone (use
#   neutron service password)
# [*keystone_tenant*]
#   Tenant from which midonet api will authenticate against Keystone (use
#   neutron service tenant)
# [*sync_db*]
#   Whether 'midonet-db-manage' should run to create and/or syncrhonize the database
#   with MidoNet specific tables. Defaults to false
#
# === Examples
#
# An example call would be:
#
#     class {'midonet::neutron_plugin':
#         midonet_api_ip    => '23.123.5.32',
#         midonet_api_port  => '8080',
#         keystone_username => 'neutron',
#         keystone_password => '32kjaxT0k3na',
#         keystone_tenant   => 'services',
#         sync_db           => true
#     }
#
# You can alternatively use the Hiera's yaml style:
#     midonet::neutron_plugin::midonet_api_ip: '23.213.5.32'
#     midonet::neutron_plugin::port: '8080'
#     midonet::neutron_plugin::keystone_username: 'neutron'
#     midonet::neutron_plugin::keystone_password: '32.kjaxT0k3na'
#     midonet::neutron_plugin::keystone_tenant: 'services'
#     midonet::neutron_plugin::sync_db: true
#
# === Authors
#
# Midonet (http://midonet.org)
#
# === Copyright
#
# Copyright (c) 2015 Midokura SARL, All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class midonet::neutron_plugin (
    $midonet_api_ip    = '127.0.0.1',
    $midonet_api_port  = '8080',
    $keystone_username = 'neutron',
    $keystone_password = undef,
    $keystone_tenant   = 'services',
    $sync_db           = false
    ) {

    require midonet::repository

    package {'python-neutron-plugin-midonet':
        ensure  => present,
        require => Exec['update-midonet-repos']
    } ->

    class {'neutron::plugins::midonet':
      midonet_api_ip    => $midonet_api_ip,
      midonet_api_port  => $midonet_api_port,
      keystone_username => $keystone_username,
      keystone_password => $keystone_password,
      keystone_tenant   => $keystone_tenant,
      sync_db           => $sync_db
    }
}
