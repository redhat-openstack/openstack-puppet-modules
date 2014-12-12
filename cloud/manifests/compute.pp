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
# == Class: cloud::compute
#
# Common class for compute nodes
#
# === Parameters:
#
# [*nova_db_host*]
#   (optional) Hostname or IP address to connect to nova database
#   Defaults to '127.0.0.1'
#
# [*nova_db_use_slave*]
#   (optional) Enable slave connection for nova, this assume
#   the haproxy is used and mysql loadbalanced port for read operation is 3307
#   Defaults to false
#
# [*nova_db_user*]
#   (optional) Username to connect to nova database
#   Defaults to 'nova'
#
# [*nova_db_password*]
#   (optional) Password to connect to nova database
#   Defaults to 'novapassword'
#
# [*rabbit_hosts*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to ['127.0.0.1:5672']
#
# [*rabbit_password*]
#   (optional) Password to connect to nova queues.
#   Defaults to 'rabbitpassword'
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance API
#   Defaults to '127.0.0.1'
#
# [*ks_glance_internal_proto*]
#   (optional) Internal protocol to connect to Glance API
#   Defaults to 'http'
#
# [*glance_api_port*]
#   (optional) TCP port to connect to Glance API
#   Defaults to '9292'
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
# [*neutron_endpoint*]
#   (optional) Host running auth service.
#   Defaults to '127.0.0.1'
#
# [*neutron_protocol*]
#   (optional) Protocol to connect to Neutron service.
#   Defaults to 'http'
#
# [*neutron_password*]
#   (optional) Password to connect to Neutron service.
#   Defaults to 'neutronpassword'
#
# [*neutron_region_name*]
#   (optional) Name of the Neutron Region.
#   Defaults to 'RegionOne'
#
# [*memcache_servers*]
#   (optionnal) Memcached servers used by Keystone. Should be an array.
#   Defaults to ['127.0.0.1:11211']
#
# [*availability_zone*]
#   (optional) Name of the default Nova availability zone.
#   Defaults to 'RegionOne'
#
# [*cinder_endpoint_type*]
#   (optional) Cinder endpoint type to use.
#   Defaults to 'publicURL'
#
class cloud::compute(
  $nova_db_host             = '127.0.0.1',
  $nova_db_use_slave        = false,
  $nova_db_user             = 'nova',
  $nova_db_password         = 'novapassword',
  $rabbit_hosts             = ['127.0.0.1:5672'],
  $rabbit_password          = 'rabbitpassword',
  $ks_glance_internal_host  = '127.0.0.1',
  $ks_glance_internal_proto = 'http',
  $glance_api_port          = 9292,
  $verbose                  = true,
  $debug                    = true,
  $use_syslog               = true,
  $log_facility             = 'LOG_LOCAL0',
  $neutron_endpoint         = '127.0.0.1',
  $neutron_protocol         = 'http',
  $neutron_password         = 'neutronpassword',
  $neutron_region_name      = 'RegionOne',
  $memcache_servers         = ['127.0.0.1:11211'],
  $availability_zone        = 'RegionOne',
  $cinder_endpoint_type     = 'publicURL'
) {

  if !defined(Resource['nova_config']) {
    resources { 'nova_config':
      purge => true;
    }
  }

  # Disable twice logging if syslog is enabled
  if $use_syslog {
    $log_dir = false
    nova_config {
      'DEFAULT/logging_context_format_string': value => '%(process)d: %(levelname)s %(name)s [%(request_id)s %(user)s] %(instance)s%(message)s';
      'DEFAULT/logging_default_format_string': value => '%(process)d: %(levelname)s %(name)s [-] %(instance)s%(message)s';
      'DEFAULT/logging_debug_format_suffix': value => '%(funcName)s %(pathname)s:%(lineno)d';
      'DEFAULT/logging_exception_prefix': value => '%(process)d: TRACE %(name)s %(instance)s';
    }
  } else {
    $log_dir = '/var/log/nova'
  }

  $encoded_user     = uriescape($nova_db_user)
  $encoded_password = uriescape($nova_db_password)

  class { 'nova':
    database_connection => "mysql://${encoded_user}:${encoded_password}@${nova_db_host}/nova?charset=utf8",
    mysql_module        => '2.2',
    rabbit_userid       => 'nova',
    rabbit_hosts        => $rabbit_hosts,
    rabbit_password     => $rabbit_password,
    glance_api_servers  => "${ks_glance_internal_proto}://${ks_glance_internal_host}:${glance_api_port}",
    memcached_servers   => $memcache_servers,
    verbose             => $verbose,
    debug               => $debug,
    log_dir             => $log_dir,
    log_facility        => $log_facility,
    use_syslog          => $use_syslog,
    nova_shell          => '/bin/bash',
  }

  if $nova_db_use_slave {
    nova_config {'database/slave_connection': value => "mysql://${encoded_user}:${encoded_password}@${nova_db_host}:3307/nova?charset=utf8" }
  } else {
    nova_config {'database/slave_connection': ensure => absent }
  }

  class { 'nova::network::neutron':
      neutron_admin_password => $neutron_password,
      neutron_admin_auth_url => "${neutron_protocol}://${neutron_endpoint}:35357/v2.0",
      neutron_url            => "${neutron_protocol}://${neutron_endpoint}:9696",
      neutron_region_name    => $neutron_region_name
  }

  nova_config {
    'DEFAULT/resume_guests_state_on_host_boot': value => true;
    'DEFAULT/default_availability_zone':        value => $availability_zone;
    'DEFAULT/servicegroup_driver':              value => 'mc';
    'DEFAULT/glance_num_retries':               value => '10';
    'DEFAULT/cinder_catalog_info':              value => "volume:cinder:${cinder_endpoint_type}";
  }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Nova DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Goneri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'nova_db_sync':
    command => 'nova-manage db sync',
    user    => 'nova',
    path    => '/usr/bin',
    unless  => "/usr/bin/mysql nova -h ${nova_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

}
