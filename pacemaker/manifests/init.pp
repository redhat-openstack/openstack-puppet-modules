# == Class: pacemaker
#
# base class for pacemaker
#
# === Parameters
#
# [*pacemaker::params::hacluster_pwd*]
#   String, used as the default for the pacemaker hacluster_pwd variable
#   Default: CHANGEME
#
# === Variables
#
# [*hacluster_pwd*]
#   used to set the password for the hacluster user on the nodes
#   this user will be used in future pacemaker releases for pcsd to
#   communicate between nodes.
#   Default: $pacemaker::params::hacluster_pwd
#
# === Dependencies
#
#  None
#
# === Examples
#
# see pacemaker::corosync
#
# === Authors
#
#  Dan Radez <dradez@redhat.com>
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
class pacemaker(
  $hacluster_pwd = $pacemaker::params::hacluster_pwd
) inherits ::pacemaker::params {
  include ::pacemaker::params
  include ::pacemaker::install
  include ::pacemaker::service
}
