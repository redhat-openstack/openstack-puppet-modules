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
# == Class: cloud::identity
#
# Install Identity Server (Keystone)
#
# === Parameters:
#
# [*identity_roles_addons*]
#   (optional) Extra keystone roles to create
#   Defaults to ['SwiftOperator', 'ResellerAdmin']
#
# [*keystone_db_host*]
#   (optional) Hostname or IP address to connect to keystone database
#   Defaults to '127.0.0.1'
#
# [*keystone_db_user*]
#   (optional) Username to connect to keystone database
#   Defaults to 'keystone'
#
# [*keystone_db_password*]
#   (optional) Password to connect to keystone database
#   Defaults to 'keystonepassword'
#
# [*memcache_servers*]
#   (optionnal) Memcached servers used by Keystone. Should be an array.
#   Defaults to ['127.0.0.1:11211']
#
# [*ks_admin_email*]
#   (optional) Email address of admin user in Keystone
#   Defaults to 'no-reply@keystone.openstack'
#
# [*ks_admin_password*]
#   (optional) Password of admin user in Keystone
#   Defaults to 'adminpassword'
#
# [*ks_admin_tenant*]
#   (optional) Admin tenant name in Keystone
#   Defaults to 'admin'
#
# [*ks_admin_token*]
#   (required) Admin token used by Keystone.
#
# [*ks_glance_internal_host*]
#   (optional) Internal Hostname or IP to connect to Glance API
#   Defaults to '127.0.0.1'
#
# [*ks_glance_admin_host*]
#   (optional) Admin Hostname or IP to connect to Glance API
#   Defaults to '127.0.0.1'
#
# [*ks_glance_public_host*]
#   (optional) Public Hostname or IP to connect to Glance API
#   Defaults to '127.0.0.1'
#
# [*ks_ceilometer_internal_host*]
#   (optional) Internal Hostname or IP to connect to Ceilometer API
#   Defaults to '127.0.0.1'
#
# [*ks_ceilometer_admin_host*]
#   (optional) Admin Hostname or IP to connect to Ceilometer API
#   Defaults to '127.0.0.1'
#
# [*ks_ceilometer_public_host*]
#   (optional) Public Hostname or IP to connect to Ceilometer API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_internal_host*]
#   (optional) Internal Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_admin_host*]
#   (optional) Admin Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_keystone_public_host*]
#   (optional) Public Hostname or IP to connect to Keystone API
#   Defaults to '127.0.0.1'
#
# [*ks_nova_internal_host*]
#   (optional) Internal Hostname or IP to connect to Nova API
#   Defaults to '127.0.0.1'
#
# [*ks_nova_admin_host*]
#   (optional) Admin Hostname or IP to connect to Nova API
#   Defaults to '127.0.0.1'
#
# [*ks_nova_public_host*]
#   (optional) Public Hostname or IP to connect to Nova API
#   Defaults to '127.0.0.1'
#
# [*ks_cinder_internal_host*]
#   (optional) Internal Hostname or IP to connect to Cinder API
#   Defaults to '127.0.0.1'
#
# [*ks_cinder_admin_host*]
#   (optional) Admin Hostname or IP to connect to Cinder API
#   Defaults to '127.0.0.1'
#
# [*ks_cinder_public_host*]
#   (optional) Public Hostname or IP to connect to Cinder API
#   Defaults to '127.0.0.1'
#
# [*ks_trove_internal_host*]
#   (optional) Internal Hostname or IP to connect to Trove API
#   Defaults to '127.0.0.1'
#
# [*ks_trove_admin_host*]
#   (optional) Admin Hostname or IP to connect to Trove API
#   Defaults to '127.0.0.1'
#
# [*ks_trove_public_host*]
#   (optional) Public Hostname or IP to connect to Trove API
#   Defaults to '127.0.0.1'
#
# [*ks_neutron_internal_host*]
#   (optional) Internal Hostname or IP to connect to Neutron API
#   Defaults to '127.0.0.1'
#
# [*ks_neutron_admin_host*]
#   (optional) Admin Hostname or IP to connect to Neutron API
#   Defaults to '127.0.0.1'
#
# [*ks_neutron_public_host*]
#   (optional) Public Hostname or IP to connect to Neutron API
#   Defaults to '127.0.0.1'
#
# [*ks_heat_internal_host*]
#   (optional) Internal Hostname or IP to connect to Heat API
#   Defaults to '127.0.0.1'
#
# [*ks_heat_admin_host*]
#   (optional) Admin Hostname or IP to connect to Heat API
#   Defaults to '127.0.0.1'
#
# [*ks_heat_public_host*]
#   (optional) Public Hostname or IP to connect to Heat API
#   Defaults to '127.0.0.1'
#
# [*ks_swift_internal_host*]
#   (optional) Internal Hostname or IP to connect to Swift API
#   Defaults to '127.0.0.1'
#
# [*ks_swift_admin_host*]
#   (optional) Admin Hostname or IP to connect to Swift API
#   Defaults to '127.0.0.1'
#
# [*ks_swift_public_host*]
#   (optional) Public Hostname or IP to connect to Swift API
#   Defaults to '127.0.0.1'
#
# [*ks_trove_password*]
#   (optional) Password used by Trove to connect to Keystone API
#   Defaults to 'trovepassword'
#
# [*ks_ceilometer_password*]
#   (optional) Password used by Ceilometer to connect to Keystone API
#   Defaults to 'ceilometerpassword'
#
# [*ks_swift_password*]
#   (optional) Password used by Swift to connect to Keystone API
#   Defaults to 'swiftpassword'
#
# [*ks_nova_password*]
#   (optional) Password used by Nova to connect to Keystone API
#   Defaults to 'novapassword'
#
# [*ks_neutron_password*]
#   (optional) Password used by Neutron to connect to Keystone API
#   Defaults to 'neutronpassword'
#
# [*ks_heat_password*]
#   (optional) Password used by Heat to connect to Keystone API
#   Defaults to 'heatpassword'
#
# [*ks_glance_password*]
#   (optional) Password used by Glance to connect to Keystone API
#   Defaults to 'glancepassword'
#
# [*ks_cinder_password*]
#   (optional) Password used by Cinder to connect to Keystone API
#   Defaults to 'cinderpassword'
#
# [*ks_swift_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_swift_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_swift_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_ceilometer_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_ceilometer_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_ceilometer_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_heat_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_heat_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_heat_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_public_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_keystone_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_nova_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_nova_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_nova_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_neutron_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_neutron_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_neutron_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_trove_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_trove_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_trove_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_glance_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_cinder_public_proto*]
#   (optional) Protocol used to connect to API. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_cinder_admin_proto*]
#   (optional) Protocol for admin endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_cinder_internal_proto*]
#   (optional) Protocol for public endpoint. Could be 'http' or 'https'.
#   Defaults to 'http'
#
# [*ks_ceilometer_public_port*]
#   (optional) TCP port to connect to Ceilometer API from public network
#   Defaults to '8777'
#
# [*ks_keystone_internal_port*]
#   (optional) TCP port to connect to Keystone API from internal network
#   Defaults to '5000'
#
# [*ks_keystone_public_port*]
#   (optional) TCP port to connect to Keystone API from public network
#   Defaults to '5000'
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone API from admin network
#   Defaults to '35357'
#
# [*ks_swift_public_port*]
#   (optional) TCP port to connect to Swift API from public network
#   Defaults to '8080'
#
# [*ks_trove_public_port*]
#   (optional) TCP port to connect to Trove API from public network
#   Defaults to '8779'
#
# [*ks_nova_public_port*]
#   (optional) TCP port to connect to Nova API from public network
#   Defaults to '8774'
#
# [*ks_ec2_public_port*]
#   (optional) TCP port to connect to EC2 API from public network
#   Defaults to '8773'
#
# [*ks_swift_dispersion_password*]
#   (optional) Password of the dispersion tenant, used for swift-dispersion-report
#   and swift-dispersion-populate tools.
#   Defaults to 'dispersion'
#
# [*ks_cinder_public_port*]
#   (optional) TCP port to connect to Cinder API from public network
#   Defaults to '8776'
#
# [*ks_neutron_public_port*]
#   (optional) TCP port to connect to Neutron API from public network
#   Defaults to '9696'
#
# [*ks_heat_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8004'
#
# [*ks_heat_cfn_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8000'
#
# [*ks_glance_api_public_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Defaults to '9292'
#
# [*api_eth*]
#   (optional) Which interface we bind the Keystone server.
#   Defaults to '127.0.0.1'
#
# [*region*]
#   (optional) OpenStack Region Name
#   Defaults to 'RegionOne'
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
# [*token_driver*]
#   (optional) Driver to store tokens
#   Defaults to 'keystone.token.backends.sql.Token'
#
# [*token_expiration*]
#   (optional) Amount of time a token should remain valid (in seconds)
#   Defaults to '3600' (1 hour)
#
# [*trove_enabled*]
#   (optional) Enable or not Trove (Database as a Service)
#   Experimental feature.
#   Defaults to false
#
# [*swift_enabled*]
#   (optional) Enable or not OpenStack Swift (Stockage as a Service)
#   Defaults to true
#
# [*ks_token_expiration*]
#   (optional) Amount of time a token should remain valid (seconds).
#   Defaults to 3600 (1 hour).
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::identity (
  $swift_enabled                = true,
  $trove_enabled                = false,
  $identity_roles_addons        = ['SwiftOperator', 'ResellerAdmin'],
  $keystone_db_host             = '127.0.0.1',
  $keystone_db_user             = 'keystone',
  $keystone_db_password         = 'keystonepassword',
  $memcache_servers             = ['127.0.0.1:11211'],
  $ks_admin_email               = 'no-reply@keystone.openstack',
  $ks_admin_password            = 'adminpassword',
  $ks_admin_tenant              = 'admin',
  $ks_admin_token               = undef,
  $ks_ceilometer_admin_host     = '127.0.0.1',
  $ks_ceilometer_internal_host  = '127.0.0.1',
  $ks_ceilometer_password       = 'ceilometerpassword',
  $ks_ceilometer_public_host    = '127.0.0.1',
  $ks_ceilometer_public_port    = 8777,
  $ks_ceilometer_public_proto   = 'http',
  $ks_ceilometer_admin_proto    = 'http',
  $ks_ceilometer_internal_proto = 'http',
  $ks_cinder_admin_host         = '127.0.0.1',
  $ks_cinder_internal_host      = '127.0.0.1',
  $ks_cinder_password           = 'cinderpassword',
  $ks_cinder_public_host        = '127.0.0.1',
  $ks_cinder_public_proto       = 'http',
  $ks_cinder_admin_proto        = 'http',
  $ks_cinder_internal_proto     = 'http',
  $ks_cinder_public_port        = 8776,
  $ks_glance_admin_host         = '127.0.0.1',
  $ks_glance_internal_host      = '127.0.0.1',
  $ks_glance_password           = 'glancepassword',
  $ks_glance_public_host        = '127.0.0.1',
  $ks_glance_public_proto       = 'http',
  $ks_glance_internal_proto     = 'http',
  $ks_glance_admin_proto        = 'http',
  $ks_glance_api_public_port    = 9292,
  $ks_heat_admin_host           = '127.0.0.1',
  $ks_heat_internal_host        = '127.0.0.1',
  $ks_heat_password             = 'heatpassword',
  $ks_heat_public_host          = '127.0.0.1',
  $ks_heat_public_proto         = 'http',
  $ks_heat_admin_proto          = 'http',
  $ks_heat_internal_proto       = 'http',
  $ks_heat_public_port          = 8004,
  $ks_heat_cfn_public_port      = 8000,
  $ks_keystone_admin_host       = '127.0.0.1',
  $ks_keystone_admin_port       = 35357,
  $ks_keystone_internal_host    = '127.0.0.1',
  $ks_keystone_internal_port    = 5000,
  $ks_keystone_public_host      = '127.0.0.1',
  $ks_keystone_public_port      = 5000,
  $ks_keystone_public_proto     = 'http',
  $ks_neutron_admin_host        = '127.0.0.1',
  $ks_keystone_admin_proto      = 'http',
  $ks_keystone_internal_proto   = 'http',
  $ks_neutron_internal_host     = '127.0.0.1',
  $ks_neutron_password          = 'neutronpassword',
  $ks_neutron_public_host       = '127.0.0.1',
  $ks_neutron_public_proto      = 'http',
  $ks_neutron_admin_proto       = 'http',
  $ks_neutron_internal_proto    = 'http',
  $ks_neutron_public_port       = 9696,
  $ks_nova_admin_host           = '127.0.0.1',
  $ks_nova_internal_host        = '127.0.0.1',
  $ks_nova_password             = 'novapassword',
  $ks_nova_public_host          = '127.0.0.1',
  $ks_nova_public_proto         = 'http',
  $ks_nova_internal_proto       = 'http',
  $ks_nova_admin_proto          = 'http',
  $ks_nova_public_port          = 8774,
  $ks_ec2_public_port           = 8773,
  $ks_swift_dispersion_password = 'dispersion',
  $ks_swift_internal_host       = '127.0.0.1',
  $ks_swift_admin_host          = '127.0.0.1',
  $ks_swift_password            = 'swiftpassword',
  $ks_swift_public_host         = '127.0.0.1',
  $ks_swift_public_port         = 8080,
  $ks_swift_public_proto        = 'http',
  $ks_swift_admin_proto         = 'http',
  $ks_swift_internal_proto      = 'http',
  $ks_trove_admin_host          = '127.0.0.1',
  $ks_trove_internal_host       = '127.0.0.1',
  $ks_trove_password            = 'trovepassword',
  $ks_trove_public_host         = '127.0.0.1',
  $ks_trove_public_port         = 8779,
  $ks_trove_public_proto        = 'http',
  $ks_trove_admin_proto         = 'http',
  $ks_trove_internal_proto      = 'http',
  $api_eth                      = '127.0.0.1',
  $region                       = 'RegionOne',
  $verbose                      = true,
  $debug                        = true,
  $log_facility                 = 'LOG_LOCAL0',
  $use_syslog                   = true,
  $ks_token_expiration          = 3600,
  $token_driver                 = 'keystone.token.backends.sql.Token',
  $firewall_settings            = {},
){

  $encoded_user     = uriescape($keystone_db_user)
  $encoded_password = uriescape($keystone_db_password)

  if $use_syslog {
    $log_dir  = false
    $log_file = false
    keystone_config {
      'DEFAULT/logging_context_format_string': value => '%(process)d: %(levelname)s %(name)s [%(request_id)s %(user_identity)s] %(instance)s%(message)s';
      'DEFAULT/logging_default_format_string': value => '%(process)d: %(levelname)s %(name)s [-] %(instance)s%(message)s';
      'DEFAULT/logging_debug_format_suffix': value => '%(funcName)s %(pathname)s:%(lineno)d';
      'DEFAULT/logging_exception_prefix': value => '%(process)d: TRACE %(name)s %(instance)s';
    }
  } else {
    $log_dir  = '/var/log/keystone'
    $log_file = 'keystone.log'
  }

# Configure Keystone
  class { 'keystone':
    enabled          => true,
    admin_token      => $ks_admin_token,
    compute_port     => $ks_nova_public_port,
    debug            => $debug,
    idle_timeout     => 60,
    log_facility     => $log_facility,
    sql_connection   => "mysql://${encoded_user}:${encoded_password}@${keystone_db_host}/keystone?charset=utf8",
    mysql_module     => '2.2',
    token_provider   => 'keystone.token.providers.uuid.Provider',
    use_syslog       => $use_syslog,
    verbose          => $verbose,
    bind_host        => $api_eth,
    log_dir          => $log_dir,
    log_file         => $log_file,
    public_port      => $ks_keystone_public_port,
    admin_port       => $ks_keystone_admin_port,
    token_driver     => $token_driver,
    token_expiration => $ks_token_expiration,
    admin_endpoint   => "${ks_keystone_admin_proto}://${ks_keystone_admin_host}:${ks_keystone_admin_port}/",
    public_endpoint  => "${ks_keystone_public_proto}://${ks_keystone_public_host}:${ks_keystone_public_port}/",
    validate_service => true,
  }

  keystone_config {
    'ec2/driver':       value => 'keystone.contrib.ec2.backends.sql.Ec2';
  }


# Keystone Endpoints + Users
  class { 'keystone::roles::admin':
    email        => $ks_admin_email,
    password     => $ks_admin_password,
    admin_tenant => $ks_admin_tenant,
  }

  keystone_role { $identity_roles_addons: ensure => present }

  class {'keystone::endpoint':
    public_url   => "${ks_keystone_public_proto}://${ks_keystone_public_host}:${ks_keystone_public_port}",
    internal_url => "${ks_keystone_internal_proto}://${ks_keystone_internal_host}:${ks_keystone_internal_port}",
    admin_url    => "${ks_keystone_admin_proto}://${ks_keystone_admin_host}:${ks_keystone_admin_port}",
    region       => $region,
  }

  # TODO(EmilienM) Disable WSGI - bug #98
  #include 'apache'
  # class {'keystone::wsgi::apache':
  #   servername  => $::fqdn,
  #   admin_port  => $ks_keystone_admin_port,
  #   public_port => $ks_keystone_public_port,
  #   # TODO(EmilienM) not sure workers is useful when using WSGI backend
  #   workers     => $::processorcount,
  #   ssl         => false
  # }

  if $swift_enabled {
    class {'swift::keystone::auth':
      password          => $ks_swift_password,
      public_address    => $ks_swift_public_host,
      public_port       => $ks_swift_public_port,
      public_protocol   => $ks_swift_public_proto,
      admin_protocol    => $ks_swift_admin_proto,
      internal_protocol => $ks_swift_internal_proto,
      admin_address     => $ks_swift_admin_host,
      internal_address  => $ks_swift_internal_host,
      region            => $region
    }

    class {'swift::keystone::dispersion':
      auth_pass => $ks_swift_dispersion_password
    }
  }

  class {'ceilometer::keystone::auth':
    admin_address     => $ks_ceilometer_admin_host,
    internal_address  => $ks_ceilometer_internal_host,
    public_address    => $ks_ceilometer_public_host,
    public_protocol   => $ks_ceilometer_public_proto,
    admin_protocol    => $ks_ceilometer_admin_proto,
    internal_protocol => $ks_ceilometer_internal_proto,
    port              => $ks_ceilometer_public_port,
    region            => $region,
    password          => $ks_ceilometer_password
  }

  class { 'nova::keystone::auth':
    cinder            => true,
    admin_address     => $ks_nova_admin_host,
    internal_address  => $ks_nova_internal_host,
    public_address    => $ks_nova_public_host,
    compute_port      => $ks_nova_public_port,
    public_protocol   => $ks_nova_public_proto,
    admin_protocol    => $ks_nova_admin_proto,
    internal_protocol => $ks_nova_internal_proto,
    ec2_port          => $ks_ec2_public_port,
    region            => $region,
    password          => $ks_nova_password
  }

  class { 'neutron::keystone::auth':
    admin_address     => $ks_neutron_admin_host,
    internal_address  => $ks_neutron_internal_host,
    public_address    => $ks_neutron_public_host,
    public_protocol   => $ks_neutron_public_proto,
    internal_protocol => $ks_neutron_internal_proto,
    admin_protocol    => $ks_neutron_admin_proto,
    port              => $ks_neutron_public_port,
    region            => $region,
    password          => $ks_neutron_password
  }

  class { 'cinder::keystone::auth':
    admin_address     => $ks_cinder_admin_host,
    internal_address  => $ks_cinder_internal_host,
    public_address    => $ks_cinder_public_host,
    port              => $ks_cinder_public_port,
    public_protocol   => $ks_cinder_public_proto,
    admin_protocol    => $ks_cinder_admin_proto,
    internal_protocol => $ks_cinder_internal_proto,
    region            => $region,
    password          => $ks_cinder_password
  }

  class { 'glance::keystone::auth':
    admin_address     => $ks_glance_admin_host,
    internal_address  => $ks_glance_internal_host,
    public_address    => $ks_glance_public_host,
    port              => $ks_glance_api_public_port,
    public_protocol   => $ks_glance_public_proto,
    internal_protocol => $ks_glance_internal_proto,
    admin_protocol    => $ks_glance_admin_proto,
    region            => $region,
    password          => $ks_glance_password
  }

  class { 'heat::keystone::auth':
    admin_address     => $ks_heat_admin_host,
    internal_address  => $ks_heat_internal_host,
    public_address    => $ks_heat_public_host,
    port              => $ks_heat_public_port,
    public_protocol   => $ks_heat_public_proto,
    internal_protocol => $ks_heat_internal_proto,
    admin_protocol    => $ks_heat_admin_proto,
    region            => $region,
    password          => $ks_heat_password
  }

  class { 'heat::keystone::auth_cfn':
    admin_address     => $ks_heat_admin_host,
    internal_address  => $ks_heat_internal_host,
    public_address    => $ks_heat_public_host,
    port              => $ks_heat_cfn_public_port,
    public_protocol   => $ks_heat_public_proto,
    internal_protocol => $ks_heat_internal_proto,
    admin_protocol    => $ks_heat_admin_proto,
    region            => $region,
    password          => $ks_heat_password
  }

  if $trove_enabled {
    class {'trove::keystone::auth':
      admin_address     => $ks_trove_admin_host,
      internal_address  => $ks_trove_internal_host,
      public_address    => $ks_trove_public_host,
      public_protocol   => $ks_trove_public_proto,
      admin_protocol    => $ks_trove_admin_proto,
      internal_protocol => $ks_trove_internal_proto,
      port              => $ks_trove_public_port,
      region            => $region,
      password          => $ks_trove_password
    }
  }

  # Purge expored tokens every days at midnight
  class { 'keystone::cron::token_flush': }

  # Note(EmilienM):
  # We check if DB tables are created, if not we populate Keystone DB.
  # It's a hack to fit with our setup where we run MySQL/Galera
  # TODO(Goneri)
  # We have to do this only on the primary node of the galera cluster to avoid race condition
  # https://github.com/enovance/puppet-openstack-cloud/issues/156
  exec {'keystone_db_sync':
    command => 'keystone-manage db_sync',
    path    => '/usr/bin',
    user    => 'keystone',
    unless  => "/usr/bin/mysql keystone -h ${keystone_db_host} -u ${encoded_user} -p${encoded_password} -e \"show tables\" | /bin/grep Tables"
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow keystone access':
      port   => $ks_keystone_public_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow keystone admin access':
      port   => $ks_keystone_admin_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-keystone_api":
    listening_service => 'keystone_api_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_keystone_public_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

  @@haproxy::balancermember{"${::fqdn}-keystone_api_admin":
    listening_service => 'keystone_api_admin_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $ks_keystone_admin_port,
    options           => 'check inter 2000 rise 2 fall 5'
  }

}
