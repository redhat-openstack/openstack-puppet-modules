# == Class: pacemaker::params
#
# Variables used by classes in the module
#
# === Dependencies
#
#  None
#
# === Authors
#
#  Crag Wolfe <cwolfe@redhat.com>
#  Jason Guiditta <jguiditt@redhat.com>
#
# === Copyright
#
# Copyright (C) 2016 Red Hat Inc.
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
class pacemaker::params {

  $hacluster_pwd         = 'CHANGEME'
  case $::osfamily {
    'redhat': {
      $pcs_bin = '/sbin/pcs'
      if $::operatingsystemrelease =~ /^6\..*$/ {
        $package_list = ['pacemaker','pcs','fence-agents','cman']
        # TODO in el6.6, $pcsd_mode should be true
        $pcsd_mode = false
        $services_manager = 'lsb'
      } else {
        $package_list = ['pacemaker','pcs','fence-agents-all','pacemaker-libs']
        $pcsd_mode = true
        $services_manager = 'systemd'
      }
      $service_name = 'pacemaker'
    }
    default: {
      case $::operatingsystem {
        default: {
          fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
        }
      }
    }
  }
}
