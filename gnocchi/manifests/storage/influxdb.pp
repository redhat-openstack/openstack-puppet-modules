#
# Copyright (C) 2015 Catalyst AU
#
# Author: Evan Giles <evan@catalyst-au.net>
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

# gnocchi::storage::influxdb
#
# influxdb driver for Gnocchi
#
# == Parameters
#
# [*influxdb_host*]
#   (optional) 'influxdb hostname'
#   Defaults to 'localhost'.
#
# [*influxdb_port*]
#   (optional) influxdb port number
#   Defaults to '8086'.
#
# [*influxdb_database*]
#   (optional) influxdb database name
#   Defaults to 'gnocchi'
#
# [*influxdb_username*]
#   (optional) influxdb username
#   Defaults to 'root'
#
# [*influxdb_password*]
#   (optional) influxdb password.
#   Defaults to undef.
#
# [*influxdb_block_until_data_ingested*]
#   (optional) influxdb block_until_data_ingested setting.
#   Defaults to 'false'.
#
class gnocchi::storage::influxdb(
  $influxdb_host                      = 'localhost',
  $influxdb_port                      = 8086,
  $influxdb_database                  = 'gnocchi',
  $influxdb_username                  = 'root',
  $influxdb_password                  = undef,
  $influxdb_block_until_data_ingested = false,
) {

  gnocchi_config {
    'storage/driver':                             value => 'influxdb';
    'storage/influxdb_host':                      value => $influxdb_host;
    'storage/influxdb_port':                      value => $influxdb_port;
    'storage/influxdb_database':                  value => $influxdb_database;
    'storage/influxdb_username':                  value => $influxdb_username;
    'storage/influxdb_password':                  value => $influxdb_password, secret => true;
    'storage/influxdb_block_until_data_ingested': value => $influxdb_block_until_data_ingested;
  }

}
