# == Define: pacemaker::property
#
# === Parameters:
#
# [*property*]
#   (required) Name of the property to set or remove
#
# [*value*]
#   (optional) Value to set the property to, required if ensure is set to
#   present
#   Defaults to undef
#
# [*node*]
#   (optional) Specific node to set the property on
#   Defaults to undef
#
# [*force*]
#   (optional) Whether to force creation of the property
#   Defaults to false
#
# [*ensure*]
#   (optional) Whether to make sure the constraint is present or absent
#   Defaults to present
#
# [*tries*]
#   (optional) How many times to attempt to create the constraint
#   Defaults to 1
#
# [*try_sleep*]
#   (optional) How long to wait between tries, in seconds
#   Defaults to 10
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
define pacemaker::property (
  $property,
  $value     = undef,
  $node      = undef,
  $force     = false,
  $ensure    = present,
  $tries     = 1,
  $try_sleep = 10,
) {
  if $property == undef {
    fail('Must provide property')
  }
  if ($ensure == 'present') and $value == undef {
    fail('When present, must provide value')
  }

  # Special-casing node branches due to https://bugzilla.redhat.com/show_bug.cgi?id=1302010
  # (Basically pcs property show <property> will show all node properties anyway)
  if $node {
    if $ensure == absent {
      exec { "Removing node-property ${property} on ${node}":
        command   => "/usr/sbin/pcs property unset --node ${node} ${property}",
        onlyif    => "/usr/sbin/pcs property show | grep ${property}= | grep ${node}",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    } else {
      if $force {
        $cmd = "/usr/sbin/pcs property set --force --node ${node} ${property}=${value}"
      } else {
        $cmd = "/usr/sbin/pcs property set --node ${node} ${property}=${value}"
      }
      exec { "Creating node-property ${property} on ${node}":
        command   => $cmd,
        unless    => "/usr/sbin/pcs property show ${property} | grep \"${property}=${value}\" | grep ${node}",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    }
  } else {
    if $ensure == absent {
      exec { "Removing cluster-wide property ${property}":
        command   => "/usr/sbin/pcs property unset ${property}",
        onlyif    => "/usr/sbin/pcs property show | grep ${property}: ",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    } else {
      if $force {
        $cmd = "/usr/sbin/pcs property set --force ${property}=${value}"
      } else {
        $cmd = "/usr/sbin/pcs property set ${property}=${value}"
      }
      exec { "Creating cluster-wide property ${property}":
        command   => $cmd,
        unless    => "/usr/sbin/pcs property show ${property} | grep \"${property} *[:=] *${value}\"",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    }
  }
}
