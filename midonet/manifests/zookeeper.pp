# == Class: ::midonet::zookeeper
#
# Install and run the zookeeper module.
#
# === Parameters
#
# [*servers*]
#   Full list of ZooKeeper servers that run in the same cluster.
# [*server_id*]
#   Identifier of this ZooKeeper server in the cluster.
# [*client_ip*]
#   IP address from where the ZooKeeper listen client requests
#
# === Examples
#
# The easiest way to run the class is:
#
#     include ::midonet::zookeeper
#
# And puppet will install a local zookeeper without cluster. For a
# clustered zookeeper, the way you have to define your puppet site, is:
#
#
# ... on Node1
#
#     class {'::midonet::zookeeper':
#         servers   =>  [{'id'   => 1
#                         'host' => 'node_1'},
#                        {'id'   => 2,
#                         'host' => 'node_2'},
#                        {'id'   => 3,
#                         'host' => 'node_3'}],
#         server_id => 1}
#
# ... on Node2
#
#     class {'::midonet::zookeeper':
#         servers   =>  [{'id'   => 1
#                         'host' => 'node_1'},
#                        {'id'   => 2,
#                         'host' => 'node_2'},
#                        {'id'   => 3,
#                         'host' => 'node_3'}],
#         server_id => 2}
#
# ... on Node3
#
#     class {'::midonet::zookeeper':
#         servers   =>  [{'id'   => 1,
#                         'host' => 'node_1'},
#                        {'id'   => 2,
#                         'host' => 'node_2'},
#                        {'id'   => 3,
#                         'host' => 'node_3'}],
#         server_id => 3}
#
# defining the same servers for each puppet node, but using a different
# server_id for each one. NOTE: node_X can be hostnames or IP addresses.
#
# you can alternatively use the Hiera.yaml style
#
#     ::midonet::zookeeper::servers:
#         - id: 1
#           host: 'node_1'
#         - id: 2
#           host: 'node_2'
#         - id: 3
#           host: 'node_3'
#     ::midonet::zookeeper::server_id: '1'
#
# This module is a passthrough to already existent 'deric-zookeeper'
# https://forge.puppetlabs.com/deric/zookeeper
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

class midonet::zookeeper($servers, $server_id, $client_ip=$::ipaddress_eth0) {

    class {'::zookeeper':
      servers   => zookeeper_servers($servers),
      id        => $server_id,
      cfg_dir   => '/etc/zookeeper',
      client_ip => $client_ip
    }
}
