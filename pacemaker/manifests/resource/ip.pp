# == Define: pacemaker::resource::ip
#
# A resource type to create pacemaker IPaddr2 resources, provided
# for convenience.
#
# === Parameters
#
# [*ensure*]
#   (optional) Whether to make sure resource is created or removed
#   Defaults to present
#
# [*ip_address*]
#   (optional) The virtual IP address you want pacemaker to create and manage
#   Defaults to undef
#
# [*cidr_netmask*]
#   (optional) The netmask to use in the cidr= option in the
#   "pcs resource create"command
#   Defaults to '32'
#
# [*nic*]
#   (optional) The nic to use in the nic= option in the "pcs resource create"
#   command
#   Defaults to ''
#
# [*group_params*]
#   (optional) Additional group parameters to pass to "pcs create", typically
#   just the name of the pacemaker resource group
#   Defaults to ''
#
# [*post_success_sleep*]
#   (optional) How long to wait acfter successful action
#   Defaults to 0
#
# [*tries*]
#   (optional) How many times to attempt to perform the action
#   Defaults to 1
#
# [*try_sleep*]
#   (optional) How long to wait between tries
#   Defaults to 0
#
# [*verify_on_create*]
#   (optional) Whether to verify creation of resource
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
define pacemaker::resource::ip(
  $ensure             = 'present',
  $ip_address         = undef,
  $cidr_netmask       = '32',
  $nic                = '',
  $group_params       = '',
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
  $verify_on_create   = false,
  ) {

  $cidr_option = $cidr_netmask ? {
      ''      => '',
      default => " cidr_netmask=${cidr_netmask}"
  }
  $nic_option = $nic ? {
      ''      => '',
      default => " nic=${nic}"
  }

  # pcs dislikes colons from IPv6 addresses. Replacing them with dots.
  $resource_name = regsubst($ip_address, '(:)', '.', 'G')

  pcmk_resource { "ip-${resource_name}":
    ensure             => $ensure,
    resource_type      => 'IPaddr2',
    resource_params    => "ip=${ip_address}${cidr_option}${nic_option}",
    group_params       => $group_params,
    post_success_sleep => $post_success_sleep,
    tries              => $tries,
    try_sleep          => $try_sleep,
    verify_on_create   => $verify_on_create,
    require            => Exec['wait-for-settle'],
  }

}
