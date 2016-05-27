# == Define: pacemaker::constraint::colocation
#
# Creates Colocation constraints for resources that need to reside together.
#
# === Parameters:
#
# [*source*]
#   (required) First resource to be grouped together
#
# [*target*]
#   (required) Second (target) resource to be grouped together
#
# [*score*]
#   (required) Numberic weighting of priority of colocation
#
# [*master_slave*]
#   (optional) Whether to set a resource with one node as master
#   Defaults to false
#
# [*ensure*]
#   (optional) Whether to make sure the constraint is present or absent
#   Defaults to present
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
define pacemaker::constraint::colocation (
  $source,
  $target,
  $score,
  $master_slave = false,
  $ensure       = present,
) {
  pcmk_constraint {"colo-${source}-${target}":
    ensure          => $ensure,
    constraint_type => colocation,
    resource        => $source,
    location        => $target,
    score           => $score,
    master_slave    => $master_slave,
    require         => Exec['wait-for-settle'],
  }
}

