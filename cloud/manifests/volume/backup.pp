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
# == Class:
#
# Volume Backup node
#
# === Parameters
#
# [*backup_ceph_pool*]
#   (optional) Name of the Ceph pool which which store the cinder backups
#   Defaults to 'backup'
#
# [*backup_ceph_user*]
#   (optional) User name used to acces to the backup rbd pool
#   Defaults to 'cinder'
#
class cloud::volume::backup(
  $backup_ceph_pool = 'backup',
  $backup_ceph_user = 'cinder'
) {

  include 'cloud::volume'

  class { 'cinder::backup': }

  # TODO(EmilienM) Disabled for now: http://git.io/kfTmcA
  # class { 'cinder::backup::ceph':
  #   backup_ceph_user => $backup_ceph_user,
  #   backup_ceph_pool => $backup_ceph_pool
  # }

}
