# == Define: pacemaker::resource::filesystem
#
# A resource type to create pacemaker Filesystem resources, provided
# for convenience.
#
# === Parameters
#
# [*ensure*]
#   (optional) Whether to make the resource present or absent
#   Defaults to present
#
# [*device*]
#   (optional) The device which is being mounted
#   For example: 192.168.200.100:/export/foo
#   Defaults to ''
#
# [*directory*]
#   (optional) Where to mount the device (the empty dir must already exist)
#   Defaults to ''
#
# [*fsoptions*]
#   (optional) Filesystem options as you would pass to mount command
#   Defaults to ''
#
# [*fstype*]
#   (optional) As you would pass to mount, for example 'nfs'
#   Defaults to ''
#
# [*meta_params*]
#   (optional) Additional meta parameters to pass to "pcs create"
#   Defaults to undef
#
# [*op_params*]
#   (optional) Additional op parameters to pass to "pcs create"
#   Defaults to ''
#
# [*clone_params*]
#   (optional) Additional clone parameters to pass to "pcs create".  Use ''
#   or true for to pass --clone to "pcs resource create" with no addtional
#   clone parameters
#   Defaults to undef
#
# [*group_params*]
#   (optional) Additional group parameters to pass to "pcs create", typically
#   just the name of the pacemaker resource group
#   Defaults to undef
#
# [*post_success_sleep*]
#   (optional) How long in seconds to wait for the next action after successful
#   action
#   Defaults to 0
#
# [*tries*]
#   (optional) How many times to attempt to create or remove the resource
#   Defaults to 1
#
# [*try_sleep*]
#   (optional) How long to wait between tries
#   Defaults to 0
#
# [*verify_on_create*]
#   (optional) Verify creation of resource
#   Defaults to false
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
define pacemaker::resource::filesystem(
  $ensure             = 'present',
  $device             = '',
  $directory          = '',
  $fsoptions          = '',
  $fstype             = '',
  $meta_params        = undef,
  $op_params          = '',
  $clone_params       = undef,
  $group_params       = undef,
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
  $verify_on_create   = false,
) {
  $resource_id = delete("fs-${directory}", '/')

  $resource_params = $fsoptions ? {
    ''      => "device=${device} directory=${directory} fstype=${fstype}",
    default => "device=${device} directory=${directory} fstype=${fstype} options=\"${fsoptions}\"",
  }

  pcmk_resource { $resource_id:
    ensure             => $ensure,
    resource_type      => 'Filesystem',
    resource_params    => $resource_params,
    meta_params        => $meta_params,
    op_params          => $op_params,
    clone_params       => $clone_params,
    group_params       => $group_params,
    post_success_sleep => $post_success_sleep,
    tries              => $tries,
    try_sleep          => $try_sleep,
    verify_on_create   => $verify_on_create,
    require            => Exec['wait-for-settle'],
  }
}
