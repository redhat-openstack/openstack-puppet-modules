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
# == Class: cloud::storage::rbd::osd
#
# Ceph OSD
#
# === Parameters:
#
# [*public_address*]
#   (optional) Which interface we bind the Ceph OSD
#   Defaults to '127.0.0.1'
#
# [*cluster_address*]
#   (optional) Which interface we bind internal the Ceph OSD
#   Defaults to '127.0.0.1'
#
# [*devices*]]
#   (optional) An array of device, should be full-qualified or short.
#   Defaults to ['sdb','/dev/sdc']
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#

class cloud::storage::rbd::osd (
  $public_address    = '127.0.0.1',
  $cluster_address   = '127.0.0.1',
  $devices           = ['sdb','/dev/sdc'],
  $firewall_settings = {},
) {

  include 'cloud::storage::rbd'

  class { 'ceph::osd' :
    public_address  => $public_address,
    cluster_address => $cluster_address,
  }

  if is_array($devices) {
    if '/dev/' in $devices {
      ceph::osd::device { $devices: }
    }
    else {
      $osd_ceph = prefix($devices,'/dev/')
      ceph::osd::device { $osd_ceph: }
    }
  }
  elsif is_hash($devices) {
    create_resources('ceph::osd::device', $devices)
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow ceph-osd access':
      port   => '6800-6810',
      extras => $firewall_settings,
    }
  }

}
