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
# == Class: cloud::storage::rbd::monitor
#
# Ceph monitor
#
# === Parameters:
#
# [*id*]
#   (optional) Then uuid of the cluster
#   Defaults to $::uniqueid
#
# [*mon_addr*]
#   (optional) Which interface we bind the Ceph monitor
#   Defaults to '127.0.0.1'
#
# [*monitor_secret*]]
#   (optional) Password of the Ceph monitor
#   Defaults to 'cephsecret'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::storage::rbd::monitor (
  $id                = $::uniqueid,
  $mon_addr          = '127.0.0.1',
  $monitor_secret    = 'cephmonsecret',
  $firewall_settings = {},
) {

  include 'cloud::storage::rbd'

  ceph::mon { $id:
    monitor_secret => $monitor_secret,
    mon_port       => 6789,
    mon_addr       => $mon_addr,
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow ceph-mon access':
      port   => '6789',
      extras => $firewall_settings,
    }
  }

}
