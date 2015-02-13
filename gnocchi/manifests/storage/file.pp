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

# gnocchi::storage::file
#
# File driver for Gnocchi
#
# == Parameters
#
# [*file_basepath*]
#   (optional) Path used to store gnocchi data files.
#   Defaults to '/var/lib/gnocchi'.
#
class gnocchi::storage::file(
  $file_basepath = '/var/lib/gnocchi',
) {

  gnocchi_config {
    'storage/driver':        value => 'file';
    'storage/file_basepath': value => $file_basepath;
  }

}
