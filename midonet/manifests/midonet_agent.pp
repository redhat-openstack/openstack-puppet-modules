# == Class: midonet::midonet_agent
#
# Install and run midonet_agent
#
# === Parameters
#
# [*zk_servers*]
#   List of hash [{ip, port}] Zookeeper instances that run in cluster.
# [*cassandra_seeds]
#   List of [ip] cassandra instances that run in cluster.
#
# === Examples
#
# The easiest way to run the class is:
#
#     include midonet::midonet_agent
#
# This call assumes that there is a zookeeper instance and a cassandra instance
# running in the target machine, and will configure the midonet-agent to
# connect to them.
#
# This is a quite naive deployment, just for demo purposes. A more realistic one
# would be:
#
#    class {'midonet::midonet_agent':
#        zk_servers              =>  [{'ip'   => 'host1',
#                                      'port' => '2183'},
#                                     {'ip'   => 'host2'}],
#        cassandra_seeds         =>  ['host1', 'host2', 'host3']
#    }
#
# Please note that Zookeeper port is not mandatory and defaulted to 2181
#
# You can alternatively use the Hiera.yaml style:
#
# midonet::midonet_agent::zk_servers:
#     - ip: 'host1'
#       port: 2183
#     - ip: 'host2'
# midonet::midonet_agent::cassandra_seeds:
#     - 'host1'
#     - 'host2'
#     - 'host3'
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

class midonet::midonet_agent($zk_servers, $cassandra_seeds) {

  class {'midonet::midonet_agent::install':
  }

  class {'midonet::midonet_agent::run':
      zk_servers => $zk_servers,
      cs_seeds   => $cassandra_seeds
  }
}
