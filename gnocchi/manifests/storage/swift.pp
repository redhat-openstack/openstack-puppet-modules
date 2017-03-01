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

# gnocchi::storage::swift
#
# Swift driver for Gnocchi
#
# == Parameters
#
# [*swift_auth_version*]
#   (optional) 'Swift authentication version to user.
#   Defaults to '1'.
#
# [*swift_authurl*]
#   (optional) Swift auth URL.
#   Defaults to 'http://localhost:8080/auth/v1.0'.
#
# [*swift_user*]
#   (optional) Swift user.
#   Defaults to 'admin:admin'
#
# [*swift_key*]
#   (optional) Swift key.
#   Defaults to 'admin'
#
# [*swift_tenant_name*]
#   (optional) Swift tenant name, only used if swift_auth_version is '2'.
#   Defaults to undef
#
class gnocchi::storage::swift(
  $swift_auth_version = '1',
  $swift_authurl      = 'http://localhost:8080/auth/v1.0',
  $swift_user         = 'admin:admin',
  $swift_key          = 'admin',
  $swift_tenant_name  = undef,
) {

  gnocchi_config {
    'storage/driver':             value => 'swift';
    'storage/swift_user':         value => $swift_user;
    'storage/swift_key':          value => $swift_key;
    'storage/swift_tenant_name':  value => $swift_tenant_name;
    'storage/swift_auth_version': value => $swift_auth_version;
    'storage/swift_authurl':      value => $swift_authurl;
  }

}
