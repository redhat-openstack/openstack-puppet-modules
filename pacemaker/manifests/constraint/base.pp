# == Define: pacemaker::constraint::base
#
# A generic constraint class.  Deprecated.  Use defined types that match the
# desired constraint instead.
#
# === Parameters:
#
# [*constraint_type*]
#   (required) Must be one of: colocation, order, location
#
# [*constraint_params*]
#   (optional) Any additional parameters needed by pcs for the constraint to be
#   properly configured
#   Defaults to undef
#
# [*first_resource*]
#   (optional) First resource to be constrained
#   Defaults to undef
#
# [*second_resource*]
#   (optional) Second resource to be constrained
#   Defaults to undef
#
# [*first_action*]
#   (optional) Only used for order constraints, action to take on first resource
#   Defaults to undef
#
# [*second_action*]
#   (optional) Only used for order constraints, action to take on second resource
#   Defaults to undef
#
# [*location*]
#   (optional) Specific location to place a resource, used only with location
#   constraint_type
#   Defaults to undef
#
# [*score*]
#   (optional) Numeric score to weight the importance of the constraint
#   Defaults to undef
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
define pacemaker::constraint::base (
  $constraint_type,
  $constraint_params = undef,
  $first_resource    = undef,
  $second_resource   = undef,
  $first_action      = undef,
  $second_action     = undef,
  $location          = undef,
  $score             = undef,
  $ensure            = present,
  $tries             = 1,
  $try_sleep         = 10,
) {

  validate_re($constraint_type, ['colocation', 'order', 'location'])

  if($constraint_type == 'order' and ($first_action == undef or $second_action == undef)) {
    fail('Must provide actions when constraint type is order')
  }

  if($constraint_type == 'location' and $location == undef) {
    fail('Must provide location when constraint type is location')
  }

  if($constraint_type == 'location' and $score == undef) {
    fail('Must provide score when constraint type is location')
  }

  if $constraint_params != undef {
    $_constraint_params = $constraint_params
  } else {
    $_constraint_params = ''
  }

  $first_resource_cleaned  = regsubst($first_resource, '(:)', '.', 'G')
  $second_resource_cleaned = regsubst($second_resource, '(:)', '.', 'G')

  if($ensure == absent) {
    if($constraint_type == 'location') {
      $name_cleaned = regsubst($name, '(:)', '.', 'G')
      exec { "Removing location constraint ${name}":
        command   => "/usr/sbin/pcs constraint location remove ${name_cleaned}",
        onlyif    => "/usr/sbin/pcs constraint location show --full | grep ${name_cleaned}",
        require   => Exec['wait-for-settle'],
        tries     => $tries,
        try_sleep => $try_sleep,
        tag       => [ 'pacemaker', 'pacemaker_constraint'],
      }
    } else {
      exec { "Removing ${constraint_type} constraint ${name}":
        command   => "/usr/sbin/pcs constraint ${constraint_type} remove ${first_resource_cleaned} ${second_resource_cleaned}",
        onlyif    => "/usr/sbin/pcs constraint ${constraint_type} show | grep ${first_resource_cleaned} | grep ${second_resource_cleaned}",
        require   => Exec['wait-for-settle'],
        tries     => $tries,
        try_sleep => $try_sleep,
        tag       => [ 'pacemaker', 'pacemaker_constraint'],
      }
    }
  } else {
    case $constraint_type {
      'colocation': {
        fail('Deprecated use pacemaker::constraint::colocation')
        exec { "Creating colocation constraint ${name}":
          command   => "/usr/sbin/pcs constraint colocation add ${first_resource_cleaned} ${second_resource_cleaned} ${score}",
          unless    => "/usr/sbin/pcs constraint colocation show | grep ${first_resource_cleaned} | grep ${second_resource_cleaned} > /dev/null 2>&1",
          require   => [Exec['wait-for-settle'],Package['pcs']],
          tries     => $tries,
          try_sleep => $try_sleep,
          tag       => [ 'pacemaker', 'pacemaker_constraint'],
        }
      }
      'order': {
        exec { "Creating order constraint ${name}":
          command   => "/usr/sbin/pcs constraint order ${first_action} ${first_resource_cleaned} then ${second_action} ${second_resource_cleaned} ${_constraint_params}",
          unless    => "/usr/sbin/pcs constraint order show | grep ${first_resource_cleaned} | grep ${second_resource_cleaned} > /dev/null 2>&1",
          require   => [Exec['wait-for-settle'],Package['pcs']],
          tries     => $tries,
          try_sleep => $try_sleep,
          tag       => [ 'pacemaker', 'pacemaker_constraint'],
        }
      }
      'location': {
        fail('Deprecated use pacemaker::constraint::location')
        exec { "Creating location constraint ${name}":
          command   => "/usr/sbin/pcs constraint location add ${name} ${first_resource_cleaned} ${location} ${score}",
          unless    => "/usr/sbin/pcs constraint location show | grep ${first_resource_cleaned} > /dev/null 2>&1",
          require   => [Exec['wait-for-settle'],Package['pcs']],
          tries     => $tries,
          try_sleep => $try_sleep,
          tag       => [ 'pacemaker', 'pacemaker_constraint'],
        }
      }
      default: {
        fail('A constraint_type mst be provided')
      }
    }
  }
}
