#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Author: Emilien Macchi <emilien.macchi@enovance.com>
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
# == Define: trove::generic_service
#
# This defined type implements basic trove services.
# It is introduced to attempt to consolidate
# common code.
#
# It also allows users to specify ad-hoc services
# as needed
#
# This define creates a service resource with title trove-${name} and
# conditionally creates a package resource with title trove-${name}
#
define trove::generic_service(
  $package_name,
  $service_name,
  $enabled        = false,
  $manage_service = true,
  $ensure_package = 'present'
) {

  include ::trove::params
  include ::trove::db::sync

  $trove_title = "trove-${name}"
  Exec['post-trove_config'] ~> Service<| title == $trove_title |>
  Exec<| title == 'trove-db-sync' |> ~> Service<| title == $trove_title |>

  if ($package_name) {
    if !defined(Package[$package_name]) {
      package { $trove_title:
        ensure => $ensure_package,
        name   => $package_name,
        notify => Service[$trove_title],
      }
    }
  }

  if $service_name {
    if $manage_service {
      if $enabled {
        $service_ensure = 'running'
      } else {
        $service_ensure = 'stopped'
      }
    }

    service { $trove_title:
      ensure    => $service_ensure,
      name      => $service_name,
      enable    => $enabled,
      hasstatus => true,
    }
  }
}
