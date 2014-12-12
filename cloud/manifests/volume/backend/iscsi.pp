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
# Configure iSCSI backend for Cinder
#
#
# === Parameters
#
# [*iscsi_ip_address*]
#   (required) IP address of iSCSI target.
#
# [*volume_group*]
#   (optional) Cinder volume group name.
#   Defaults to 'cinder-volumes'.
#
define cloud::volume::backend::iscsi (
  $iscsi_ip_address,
  $volume_group        = 'cinder-volumes',
  $volume_backend_name = $name,
) {


  cinder::backend::iscsi { $name:
    iscsi_ip_address => $iscsi_ip_address,
    volume_group     => $volume_group,
  }

  @cinder::type { $volume_backend_name:
    set_key   => 'volume_backend_name',
    set_value => $volume_backend_name,
    notify    => Service['cinder-volume']
  }
}
