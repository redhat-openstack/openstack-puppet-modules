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
# Configure NFS backend for Cinder
#
#
# === Parameters
#
# [*nfs_servers*]
#   (required) Array of NFS servers in the form 'ipaddress:/share'
#
# [*nfs_mount_options*]
#   (optional) Mount options passed to the nfs client. See section
#   of the nfs man page for details.
#   Defaults to undef
#
# [*nfs_disk_util*]
#   (optional) Use du or df for free space calculation
#   Defaults to undef
#
# [*nfs_sparsed_volumes*]
#   (optional) Create volumes as sparsed files which take no space.
#   If set to 'false' volume is created as regular file.
#   In such case volume creation takes a lot of time.
#   Defaults to undef
#
# [*nfs_mount_point_base*]
#   (optional) Base dir containing mount points for nfs shares.
#   Defaults to undef
#
# [*nfs_shares_config*]
#   (optional) File with the list of available NFS shares.
#   Defaults to '/etc/cinder/shares.conf'
#
# [*nfs_used_ratio*]
#   (optional) Percent of ACTUAL usage of the underlying volume
#   before no new volumes can be allocated to the volume destination.
#   Defaults to 0.95
#
# [*nfs_oversub_ratio*]
#   (optional) This will compare the allocated to available space on
#   the volume destination.  If the ratio exceeds this number, the
#   destination will no longer be valid.
#   Defaults to 1.0
#
define cloud::volume::backend::nfs(
  $volume_backend_name = $name,
  $nfs_servers = [],
  $nfs_mount_options = undef,
  $nfs_disk_util = undef,
  $nfs_sparsed_volumes = undef,
  $nfs_mount_point_base = undef,
  $nfs_shares_config = '/etc/cinder/shares.conf',
  $nfs_used_ratio = '0.95',
  $nfs_oversub_ratio = '1.0',
) {

  cinder::backend::nfs { $name:
    volume_backend_name  => $volume_backend_name,
    nfs_servers          => $nfs_servers,
    nfs_mount_options    => $nfs_mount_options,
    nfs_disk_util        => $nfs_disk_util,
    nfs_sparsed_volumes  => $nfs_sparsed_volumes,
    nfs_mount_point_base => $nfs_mount_point_base,
    nfs_shares_config    => $nfs_shares_config,
    nfs_used_ratio       => $nfs_used_ratio,
    nfs_oversub_ratio    => $nfs_oversub_ratio,
  }

  @cinder::type { $volume_backend_name:
    set_key   => 'volume_backend_name',
    set_value => $volume_backend_name,
    notify    => Service['cinder-volume']
  }
}
