# == Class: cinder::backup::swift
#
# Setup Cinder to backup volumes into Swift
#
# === Parameters
#
# [*backup_driver*]
#   (Optional) The backup driver for Swift back-end.
#   Defaults to 'cinder.backup.drivers.swift'.
#
# [*backup_swift_url*]
#   (optional) The URL of the Swift endpoint.
#   Should be a valid Swift URL
#   Defaults to 'http://localhost:8080/v1/AUTH_'
#
# [*backup_swift_auth_url*]
#  (optional) The URL of the Keystone endpoint for authentication.
#  Defaults to 'http://127.0.0.1:5000/v2.0/'
#
# [*backup_swift_container*]
#   (optional) The default Swift container to use.
#   Defaults to 'volumes_backup'
#
# [*backup_swift_object_size*]
#   (optional) The size in bytes of Swift backup objects.
#   Defaults to $::os_service_default
#
# [*backup_swift_retry_attempts*]
#   (optional) The number of retries to make for Swift operations.
#   Defaults to $::os_service_default
#
# [*backup_swift_retry_backoff*]
#   (optional) The backoff time in seconds between Swift retries.
#   Defaults to $::os_service_default
#
# [*backup_compression_algorithm*]
#   (optional) The compression algorithm for the chunks sent to swift
#   Defaults to $::os_service_default
#   set to None to disable compression
#
# === Author(s)
#
# Emilien Macchi <emilien.macchi@enovance.com>
#
# === Copyright
#
# Copyright (C) 2013 eNovance SAS <licensing@enovance.com>
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
#
class cinder::backup::swift (
  $backup_driver                = 'cinder.backup.drivers.swift',
  $backup_swift_url             = 'http://localhost:8080/v1/AUTH_',
  $backup_swift_auth_url        = 'http://127.0.0.1:5000/v2.0/',
  $backup_swift_container       = 'volumes_backup',
  $backup_swift_object_size     = $::os_service_default,
  $backup_swift_retry_attempts  = $::os_service_default,
  $backup_swift_retry_backoff   = $::os_service_default,
  $backup_compression_algorithm = $::os_service_default,
) {

  if ($backup_swift_container == 'volumes_backup') {
    warning('The OpenStack default value of backup_swift_container differs from the puppet module default of "volumes_backup" and will be changed to the upstream OpenStack default in N-release.')
  }

  cinder_config {
    'DEFAULT/backup_driver':                value => $backup_driver;
    'DEFAULT/backup_swift_url':             value => $backup_swift_url;
    'DEFAULT/backup_swift_auth_url':        value => $backup_swift_auth_url;
    'DEFAULT/backup_swift_container':       value => $backup_swift_container;
    'DEFAULT/backup_swift_object_size':     value => $backup_swift_object_size;
    'DEFAULT/backup_swift_retry_attempts':  value => $backup_swift_retry_attempts;
    'DEFAULT/backup_swift_retry_backoff':   value => $backup_swift_retry_backoff;
    'DEFAULT/backup_compression_algorithm': value => $backup_compression_algorithm;
  }

}
