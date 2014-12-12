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
# == Class: cloud::database::dbaas
#
# Common class to install OpenStack Database as a Service (Trove)
#
# === Parameters:
#
# [*trove_db_host*]
#   (optional) Hostname or IP address to connect to trove database
#   Defaults to '127.0.0.1'
#
# [*trove_db_user*]
#   (optional) Username to connect to trove database
#   Defaults to 'trove'
#
# [*trove_db_password*]
#   (optional) Password to connect to trove database
#   Defaults to 'trovepassword'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*nova_admin_username*]
#   (optional) Trove username used to connect to nova.
#   Defaults to 'trove'
#
# [*nova_admin_password*]
#   (optional) Trove password used to connect to nova.
#   Defaults to 'trovepassword'
#
# [*nova_admin_tenant_name*]
#   (optional) Trove tenant name used to connect to nova.
#   Defaults to 'services'
#
class cloud::database::dbaas(
  $trove_db_host                = '127.0.0.1',
  $trove_db_user                = 'trove',
  $trove_db_password            = 'trovepassword',
  $rabbit_hosts                 = ['127.0.0.1:5672'],
  $rabbit_password              = 'rabbitpassword',
  $nova_admin_username          = 'trove',
  $nova_admin_tenant_name       = 'services',
  $nova_admin_password          = 'trovepassword',
) {

  $encoded_user     = uriescape($trove_db_user)
  $encoded_password = uriescape($trove_db_password)

  class { 'trove':
    database_connection          => "mysql://${encoded_user}:${encoded_password}@${trove_db_host}/trove?charset=utf8",
    mysql_module                 => '2.2',
    rabbit_hosts                 => $rabbit_hosts,
    rabbit_password              => $rabbit_password,
    rabbit_userid                => 'trove',
    nova_proxy_admin_pass        => $nova_admin_password,
    nova_proxy_admin_user        => $nova_admin_username,
    nova_proxy_admin_tenant_name => $nova_admin_tenant_name
  }

  exec {'trove_db_sync':
    command => 'trove-manage db_sync',
    user    => 'trove',
    path    => '/usr/bin',
    unless  => "/usr/bin/mysql trove -h ${trove_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

}
