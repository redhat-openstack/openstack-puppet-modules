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
#
# == Class: cloud::volume
#
# Common class for volume nodes
#
# === Parameters:
#
# [*cinder_db_host*]
#   (optional) Cinder database host
#   Defaults to '127.0.0.1'
#
# [*cinder_db_user*]
#   (optional) Cinder database user
#   Defaults to 'cinder'
#
# [*cinder_db_password*]
#   (optional) Cinder database password
#   Defaults to 'cinderpassword'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to cinder queues.
#   Defaults to 'rabbitpassword'
#
# [*verbose*]
#   (optional) Set log output to verbose output
#   Defaults to true
#
# [*debug*]
#   (optional) Set log output to debug output
#   Defaults to true
#
# [*use_syslog*]
#   (optional) Use syslog for logging
#   Defaults to true
#
# [*log_facility*]
#   (optional) Syslog facility to receive log lines
#   Defaults to 'LOG_LOCAL0'
#
# [*storage_availability_zone*]
#   (optional) The storage availability zone
#   Defaults to 'nova'
#
# [*nova_endpoint_type*]
#   (optional) The type of the OpenStack endpoint (public/internal/admin) URL
#   Defaults to 'publicURL'
#
class cloud::volume(
  $cinder_db_host             = '127.0.0.1',
  $cinder_db_user             = 'cinder',
  $cinder_db_password         = 'cinderpassword',
  $rabbit_hosts               = ['127.0.0.1:5672'],
  $rabbit_password            = 'rabbitpassword',
  $verbose                    = true,
  $debug                      = true,
  $log_facility               = 'LOG_LOCAL0',
  $storage_availability_zone  = 'nova',
  $use_syslog                 = true,
  $nova_endpoint_type         = 'publicURL'
) {

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
    cinder_config {
      'DEFAULT/logging_context_format_string': value => '%(process)d: %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s';
      'DEFAULT/logging_default_format_string': value => '%(process)d: %(levelname)s %(name)s [-] %(instance)s%(message)s';
      'DEFAULT/logging_debug_format_suffix': value => '%(funcName)s %(pathname)s:%(lineno)d';
      'DEFAULT/logging_exception_prefix': value => '%(process)d: TRACE %(name)s %(instance)s';
    }
  } else {
    $log_dir = '/var/log/cinder'
  }

  $encoded_user = uriescape($cinder_db_user)
  $encoded_password = uriescape($cinder_db_password)


  class { 'cinder':
    sql_connection            => "mysql://${encoded_user}:${encoded_password}@${cinder_db_host}/cinder?charset=utf8",
    mysql_module              => '2.2',
    rabbit_userid             => 'cinder',
    rabbit_hosts              => $rabbit_hosts,
    rabbit_password           => $rabbit_password,
    rabbit_virtual_host       => '/',
    verbose                   => $verbose,
    debug                     => $debug,
    log_dir                   => $log_dir,
    log_facility              => $log_facility,
    use_syslog                => $use_syslog,
    storage_availability_zone => $storage_availability_zone
  }

  cinder_config {
    'DEFAULT/nova_catalog_info': value => "compute:nova:${nova_endpoint_type}";
  }

  class { 'cinder::ceilometer': }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Cinder DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Goneri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'cinder_db_sync':
    command => 'cinder-manage db sync',
    path    => '/usr/bin',
    user    => 'cinder',
    unless  => "/usr/bin/mysql cinder -h ${cinder_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

}
