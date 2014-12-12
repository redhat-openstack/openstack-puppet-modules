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
# == Class: cloud::database::nosql
#
# Install a nosql server (MongoDB)
#
# === Parameters:
#
# [*bind_ip*]
#   (optional) IP address on which mongod instance should listen
#   Defaults to '127.0.0.1'
#
# [*nojournal*]
#   (optional) Disable mongodb internal cache. This is not recommended for
#   production but results in a much faster boot process.
#   http://docs.mongodb.org/manual/reference/configuration-options/#nojournal
#   Defaults to false
#
# [*replset_members*]
#   (optional) Ceilometer Replica set members hostnames
#   Should be an array. Example: ['node1', 'node2', node3']
#   If set to false, the setup won't be HA and no replicaset will be created.
#   Defaults to hostname
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::database::nosql(
  $bind_ip           = '127.0.0.1',
  $nojournal         = false,
  $replset_members   = $::hostname,
  $firewall_settings = {},
) {

  # should be an array
  $array_bind_ip         = any2array($bind_ip)
  $array_replset_members = any2array($replset_members)

  # Red Hat & CentOS use packages from RHCL or EPEL to support systemd
  # so manage_package_repo should be at false regarding to mongodb module
  if $::osfamily == 'RedHat' {
    $manage_package_repo = false
  } else {
  # Debian & Ubuntu are picked from mongodb repo to get recent version
    $manage_package_repo = true
  }

  class { 'mongodb::globals':
    manage_package_repo => $manage_package_repo
  }->
  class { 'mongodb':
    bind_ip   => $array_bind_ip,
    nojournal => $nojournal,
    replset   => 'ceilometer',
    logpath   => '/var/log/mongodb/mongod.log',
  }

  exec {'check_mongodb' :
    command   => "/usr/bin/mongo ${bind_ip}:27017",
    logoutput => false,
    tries     => 60,
    try_sleep => 5,
    require   => Service['mongodb'],
  }

  if $replset_members {
    mongodb_replset{'ceilometer':
      members => $array_replset_members,
      before  => Anchor['mongodb setup done'],
    }
  }

  anchor {'mongodb setup done' :
    require => Exec['check_mongodb'],
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow mongodb access':
      port   => '27017',
      extras => $firewall_settings,
    }
  }

}
