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
# == Class: cloud::object::ringbuilder
#
# Swift ring builder node
#
# === Parameters:
#
# [*enabled*]
#   (optional) Enable or not the Swift ringbuilder rsync server
#   Defaults to false
#
# [*rsyncd_ipaddress*]
#   (optional) Hostname or IP of the swift ringbuilder rsync daemon
#   Defaults to '127.0.0.1'
#
# [*replicas*]
#   (optional) Number of replicas to kept
#   Defaults to '3'
#
# [*swift_rsync_max_connections*]
#   (optional) Max number of connections to the rsync daemon
#   Defaults to '5'
#
class cloud::object::ringbuilder(
  $enabled                     = false,
  $rsyncd_ipaddress            = '127.0.0.1',
  $replicas                    = 3,
  $swift_rsync_max_connections = 5,
) {

  include cloud::object

  if $enabled {
    Ring_object_device <<| |>>
    Ring_container_device <<| |>>
    Ring_account_device <<| |>>

    class {'swift::ringbuilder' :
      part_power     => 15,
      replicas       => $replicas,
      min_part_hours => 24,
    }

    class {'swift::ringserver' :
      local_net_ip    => $rsyncd_ipaddress,
      max_connections => $swift_rsync_max_connections,
    }

    # exports rsync gets that can be used to sync the ring files
    @@swift::ringsync { ['account', 'object', 'container']:
      ring_server => $rsyncd_ipaddress,
    }
  }

}

