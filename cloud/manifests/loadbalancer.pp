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
# == Class: cloud::loadbalancer
#
# Install Load-Balancer node (HAproxy + Keepalived)
#
# === Parameters:
#
# [*keepalived_vrrp_interface*]
#  (optional) Networking interface to bind the vrrp traffic.
#  Defaults to false (disabled)
#
# [*keepalived_public_interface*]
#   (optional) Networking interface to bind the VIP connected to public network.
#   Defaults to 'eth0'
#
# [*keepalived_internal_interface*]
#   (optional) Networking interface to bind the VIP connected to internal network.
#   keepalived_internal_ipvs should be configured to enable the internal VIP.
#   Defaults to 'eth1'
#
# [*keepalived_public_ipvs*]
#   (optional) IP address of the VIP connected to public network.
#   Should be an array.
#   Defaults to ['127.0.0.1']
#
# [*keepalived_internal_ipvs*]
#   (optional) IP address of the VIP connected to internal network.
#   Should be an array.
#   Defaults to false (disabled)
#
# [*keepalived_auth_type*]
#   (optional) Authentication method.
#   Supported methods are simple Passwd (PASS) or IPSEC AH (AH).
#   Defaults to undef
#
# [*keepalived_auth_pass*]
#   (optional) Authentication password.
#   Password string (up to 8 characters).
#   Defaults to undef
#
# [*swift_api*]
#   (optional) Enable or not Swift public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*ceilometer_api*]
#   (optional) Enable or not Ceilometer public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*cinder_api*]
#   (optional) Enable or not Cinder public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*glance_api*]
#   (optional) Enable or not Glance API public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*glance_registry*]
#   (optional) Enable or not Glance Registry public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*neutron_api*]
#   (optional) Enable or not Neutron public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*heat_api*]
#   (optional) Enable or not Heat public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*heat_cfn_api*]
#   (optional) Enable or not Heat CFN public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*heat_cloudwatch_api*]
#   (optional) Enable or not Heat Cloudwatch public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*nova_api*]
#   (optional) Enable or not Nova public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*trove_api*]
#   (optional) Enable or not Trove public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*horizon*]
#   (optional) Enable or not Horizon public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*horizon_ssl*]
#   (optional) Enable or not Horizon SSL public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*ec2_api*]
#   (optional) Enable or not EC2 public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*spice*]
#   (optional) Enable or not spice binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to false
#
# [*metadata_api*]
#   (optional) Enable or not Metadata public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*keystone_api*]
#   (optional) Enable or not Keystone public binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*rabbitmq*]
#   (optional) Enable or not RabbitMQ binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure.
#   Defaults to false
#
# [*keystone_api_admin*]
#   (optional) Enable or not Keystone admin binding.
#   If true, both public and internal will attempt to be created except if vip_internal_ip is set to false.
#   If set to ['10.0.0.1'], only IP in the array (or in the string) will be configured in the pool. They must be part of keepalived_ip options.
#   If set to false, no binding will be configure
#   Defaults to true
#
# [*haproxy_auth*]
#  (optional) The HTTP sytle basic credentials (using login:password form)
#  Defaults to 'admin:changeme'
#
# [*keepalived_state*]
#  (optional) TODO
#  Defaults to 'BACKUP'
#
# [*keepalived_priority*]
#  (optional) TODO
#  Defaults to '50'
#
# [*ceilometer_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*cinder_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*ec2_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*glance_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*glance_registry_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*heat_cfn_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*heat_cloudwatch_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*heat_api_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*keystone_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*keystone_admin_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*metadata_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*neutron_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*nova_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*trove_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*swift_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*spice_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*horizon_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*horizon_ssl_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*rabbitmq_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*galera_bind_options*]
#   (optional) A hash of options that are inserted into the HAproxy listening
#   service configuration block.
#   Defaults to []
#
# [*ks_ceilometer_public_port*]
#   (optional) TCP port to connect to Ceilometer API from public network
#   Defaults to '8777'
#
# [*ks_cinder_public_port*]
#   (optional) TCP port to connect to Cinder API from public network
#   Defaults to '8776'
#
# [*ks_ec2_public_port*]
#   (optional) TCP port to connect to EC2 API from public network
#   Defaults to '8773'
#
# [*ks_glance_api_public_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Defaults to '9292'
#
# [*ks_glance_registry_internal_port*]
#   (optional) TCP port to connect to Glance API from public network
#   Defaults to '9191'
#
# [*ks_heat_cfn_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8000'
#
# [*ks_heat_cloudwatch_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8003'
#
# [*ks_heat_public_port*]
#   (optional) TCP port to connect to Heat API from public network
#   Defaults to '8004'
#
# [*ks_keystone_admin_port*]
#   (optional) TCP port to connect to Keystone Admin API from public network
#   Defaults to '35357'
#
# [*ks_keystone_public_port*]
#   (optional) TCP port to connect to Keystone API from public network
#   Defaults to '5000'
#
# [*ks_metadata_public_port*]
#   (optional) TCP port to connect to Keystone metadata API from public network
#   Defaults to '8775'
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
# [*ks_neutron_public_port*]
#   (optional) TCP port to connect to Neutron API from public network
#   Defaults to '9696'
#
# [*horizon_port*]
#   (optional) Port used to connect to OpenStack Dashboard
#   Defaults to '80'
#
# [*horizon_ssl_port*]
#   (optional) Port used to connect to OpenStack Dashboard using SSL
#   Defaults to '443'
#
# [*spice_port*]
#   (optional) TCP port to connect to Nova spicehtmlproxy service.
#   Defaults to '6082'
#
# [*rabbitmq_port*]
#   (optional) Port of RabbitMQ service.
#   Defaults to '5672'
#
# [*vip_public_ip*]
#  (optional) Array or string for public VIP
#  Should be part of keepalived_public_ips
#  Defaults to '127.0.0.2'
#
# [*vip_internal_ip*]
#  (optional) Array or string for internal VIP
#  Should be part of keepalived_internal_ips
#  Defaults to false
#
# [*vip_monitor_ip*]
#  (optional) Array or string for monitor VIP
#  Defaults to false
#
# [*galera_ip*]
#  (optional) An array of Galera IP
#  Defaults to ['127.0.0.1']
#
# [*galera_slave*]
#  (optional) A boolean to configure galera slave
#  Defaults to false
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::loadbalancer(
  $swift_api                        = true,
  $ceilometer_api                   = true,
  $cinder_api                       = true,
  $glance_api                       = true,
  $glance_registry                  = true,
  $neutron_api                      = true,
  $heat_api                         = true,
  $heat_cfn_api                     = true,
  $heat_cloudwatch_api              = true,
  $nova_api                         = true,
  $ec2_api                          = true,
  $metadata_api                     = true,
  $keystone_api                     = true,
  $keystone_api_admin               = true,
  $trove_api                        = true,
  $horizon                          = true,
  $horizon_ssl                      = false,
  $rabbitmq                         = false,
  $spice                            = true,
  $haproxy_auth                     = 'admin:changeme',
  $keepalived_state                 = 'BACKUP',
  $keepalived_priority              = '50',
  $keepalived_vrrp_interface        = false,
  $keepalived_public_interface      = 'eth0',
  $keepalived_public_ipvs           = ['127.0.0.1'],
  $keepalived_internal_interface    = 'eth1',
  $keepalived_internal_ipvs         = false,
  $keepalived_auth_type             = false,
  $keepalived_auth_pass             = false,
  $ceilometer_bind_options          = [],
  $cinder_bind_options              = [],
  $ec2_bind_options                 = [],
  $glance_api_bind_options          = [],
  $glance_registry_bind_options     = [],
  $heat_cfn_bind_options            = [],
  $heat_cloudwatch_bind_options     = [],
  $heat_api_bind_options            = [],
  $keystone_bind_options            = [],
  $keystone_admin_bind_options      = [],
  $metadata_bind_options            = [],
  $neutron_bind_options             = [],
  $nova_bind_options                = [],
  $trove_bind_options               = [],
  $swift_bind_options               = [],
  $spice_bind_options               = [],
  $horizon_bind_options             = [],
  $horizon_ssl_bind_options         = [],
  $rabbitmq_bind_options            = [],
  $galera_bind_options              = [],
  $ks_ceilometer_public_port        = 8777,
  $ks_cinder_public_port            = 8776,
  $ks_ec2_public_port               = 8773,
  $ks_glance_api_public_port        = 9292,
  $ks_glance_registry_internal_port = 9191,
  $ks_heat_cfn_public_port          = 8000,
  $ks_heat_cloudwatch_public_port   = 8003,
  $ks_heat_public_port              = 8004,
  $ks_keystone_admin_port           = 35357,
  $ks_keystone_public_port          = 5000,
  $ks_metadata_public_port          = 8775,
  $ks_neutron_public_port           = 9696,
  $ks_nova_public_port              = 8774,
  $ks_swift_public_port             = 8080,
  $ks_trove_public_port             = 8779,
  $rabbitmq_port                    = 5672,
  $horizon_port                     = 80,
  $horizon_ssl_port                 = 443,
  $spice_port                       = 6082,
  $vip_public_ip                    = ['127.0.0.1'],
  $vip_internal_ip                  = false,
  $vip_monitor_ip                   = false,
  $galera_ip                        = ['127.0.0.1'],
  $galera_slave                     = false,
  $firewall_settings                = {},
){

  include cloud::params

  if $keepalived_vrrp_interface {
    $keepalived_vrrp_interface_real = $keepalived_vrrp_interface
  } else {
    $keepalived_vrrp_interface_real = $keepalived_public_interface
  }

  # Fail if OpenStack and Galera VIP are  not in the VIP list
  if $vip_public_ip and !(member(any2array($keepalived_public_ipvs), $vip_public_ip)) {
    fail('vip_public_ip should be part of keepalived_public_ipvs.')
  }
  if $vip_internal_ip and !(member(any2array($keepalived_internal_ipvs),$vip_internal_ip)) {
    fail('vip_internal_ip should be part of keepalived_internal_ipvs.')
  }
  if $galera_ip and !((member(any2array($keepalived_public_ipvs),$galera_ip)) or (member(any2array($keepalived_internal_ipvs),$galera_ip))) {
    fail('galera_ip should be part of keepalived_public_ipvs or keepalived_internal_ipvs.')
  }

  # Ensure Keepalived is started before HAproxy to avoid binding errors.
  class { 'keepalived': } ->
  class { 'haproxy':
    service_manage => true
  }

  keepalived::vrrp_script { 'haproxy':
    name_is_process => $::cloud::params::keepalived_name_is_process,
    script          => $::cloud::params::keepalived_vrrp_script,
  }

  keepalived::instance { '1':
    interface     => $keepalived_vrrp_interface_real,
    virtual_ips   => unique(split(join(flatten([$keepalived_public_ipvs, ['']]), " dev ${keepalived_public_interface},"), ',')),
    state         => $keepalived_state,
    track_script  => ['haproxy'],
    priority      => $keepalived_priority,
    auth_type     => $keepalived_auth_type,
    auth_pass     => $keepalived_auth_pass,
    notify_master => $::cloud::params::start_haproxy_service,
    notify_backup => $::cloud::params::stop_haproxy_service,
  }


  # If using an internal VIP, allow to use a dedicated interface for VRRP traffic.
  # First we check if internal binding is enabled
  if $keepalived_internal_ipvs {
    # Then we validate this is not the same as public binding
    if !empty(difference(any2array($keepalived_internal_ipvs), any2array($keepalived_public_ipvs))) {
      if ! $keepalived_vrrp_interface {
        $keepalived_vrrp_interface_internal = $keepalived_internal_interface
      } else {
        $keepalived_vrrp_interface_internal = $keepalived_vrrp_interface
      }
      keepalived::instance { '2':
        interface     => $keepalived_vrrp_interface_internal,
        virtual_ips   => unique(split(join(flatten([$keepalived_internal_ipvs, ['']]), " dev ${keepalived_internal_interface},"), ',')),
        state         => $keepalived_state,
        track_script  => ['haproxy'],
        priority      => $keepalived_priority,
        auth_type     => $keepalived_auth_type,
        auth_pass     => $keepalived_auth_pass,
        notify_master => $::cloud::params::start_haproxy_service,
        notify_backup => $::cloud::params::stop_haproxy_service,
      }
    }
  }

  file { '/etc/logrotate.d/haproxy':
    ensure  => file,
    source  => 'puppet:///modules/cloud/logrotate/haproxy',
    owner   => root,
    group   => root,
    mode    => '0644';
  }

  if $vip_monitor_ip {
    $vip_monitor_ip_real = $vip_monitor_ip
  } else {
    $vip_monitor_ip_real = $vip_public_ip
  }

  haproxy::listen { 'monitor':
    ipaddress => $vip_monitor_ip_real,
    ports     => '9300',
    options   => {
      'mode'        => 'http',
      'monitor-uri' => '/status',
      'stats'       => ['enable','uri     /admin','realm   Haproxy\ Statistics',"auth    ${haproxy_auth}", 'refresh 5s' ],
      ''            => template('cloud/loadbalancer/monitor.erb'),
    }
  }

  # Instanciate HAproxy binding
  cloud::loadbalancer::binding { 'keystone_api_cluster':
    ip                => $keystone_api,
    port              => $ks_keystone_public_port,
    bind_options      => $keystone_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'keystone_api_admin_cluster':
    ip                => $keystone_api_admin,
    port              => $ks_keystone_admin_port,
    bind_options      => $keystone_admin_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'swift_api_cluster':
    ip                => $swift_api,
    port              => $ks_swift_public_port,
    bind_options      => $swift_bind_options,
    httpchk           => 'httpchk /healthcheck',
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'nova_api_cluster':
    ip                => $nova_api,
    port              => $ks_nova_public_port,
    bind_options      => $nova_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'ec2_api_cluster':
    ip                => $ec2_api,
    port              => $ks_ec2_public_port,
    bind_options      => $ec2_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'metadata_api_cluster':
    ip                => $metadata_api,
    port              => $ks_metadata_public_port,
    bind_options      => $metadata_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'spice_cluster':
    ip                => $spice,
    port              => $spice_port,
    options           => {
      'mode'           => 'tcp',
      'option'         => ['tcpka', 'tcplog', 'forwardfor'],
      'balance'        => 'source',
      'timeout server' => '120m',
      'timeout client' => '120m',
    },
    bind_options      => $spice_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'rabbitmq_cluster':
    ip                => $rabbitmq,
    port              => $rabbitmq_port,
    options           => {
      'mode'    => 'tcp',
      'option'  => ['tcpka', 'tcplog', 'forwardfor'],
      'balance' => 'roundrobin',
    },
    bind_options      => $rabbitmq_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'trove_api_cluster':
    ip                => $trove_api,
    port              => $ks_trove_public_port,
    bind_options      => $trove_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'glance_api_cluster':
    ip                => $glance_api,
    options           => {
      'mode'           => 'tcp',
      'balance'        => 'source',
      'option'         => ['tcpka', 'tcplog', 'forwardfor'],
      'timeout server' => '120m',
      'timeout client' => '120m',
    },
    port              => $ks_glance_api_public_port,
    bind_options      => $glance_api_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'glance_registry_cluster':
    ip                => $glance_registry,
    port              => $ks_glance_registry_internal_port,
    bind_options      => $glance_registry_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'neutron_api_cluster':
    ip                => $neutron_api,
    port              => $ks_neutron_public_port,
    bind_options      => $neutron_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'cinder_api_cluster':
    ip                => $cinder_api,
    port              => $ks_cinder_public_port,
    bind_options      => $cinder_bind_options,
    firewall_settings => $firewall_settings,
  }
  cloud::loadbalancer::binding { 'ceilometer_api_cluster':
    ip                => $ceilometer_api,
    port              => $ks_ceilometer_public_port,
    bind_options      => $ceilometer_bind_options,
    firewall_settings => $firewall_settings,
  }
  if 'ssl' in $heat_api_bind_options {
    $heat_api_options = {
    'reqadd'  => 'X-Forwarded-Proto:\ https if { ssl_fc }' }
  } else {
    $heat_api_options = {}
  }
  cloud::loadbalancer::binding { 'heat_api_cluster':
    ip                => $heat_api,
    port              => $ks_heat_public_port,
    bind_options      => $heat_api_bind_options,
    options           => $heat_api_options,
    firewall_settings => $firewall_settings,
  }
  if 'ssl' in $heat_cfn_bind_options {
    $heat_cfn_options = {
    'reqadd'  => 'X-Forwarded-Proto:\ https if { ssl_fc }' }
  } else {
    $heat_cfn_options = { }
  }
  cloud::loadbalancer::binding { 'heat_cfn_api_cluster':
    ip                => $heat_cfn_api,
    port              => $ks_heat_cfn_public_port,
    bind_options      => $heat_cfn_bind_options,
    options           => $heat_cfn_options,
    firewall_settings => $firewall_settings,
  }
  if 'ssl' in $heat_cloudwatch_bind_options {
    $heat_cloudwatch_options = {
    'reqadd'  => 'X-Forwarded-Proto:\ https if { ssl_fc }' }
  } else {
    $heat_cloudwatch_options = { }
  }
  cloud::loadbalancer::binding { 'heat_cloudwatch_api_cluster':
    ip                => $heat_cloudwatch_api,
    port              => $ks_heat_cloudwatch_public_port,
    bind_options      => $heat_cloudwatch_bind_options,
    options           => $heat_cloudwatch_options,
    firewall_settings => $firewall_settings,
  }

  $horizon_ssl_options = {
    'mode'    => 'tcp',
    'cookie'  => 'sessionid prefix',
    'balance' => 'leastconn'
  }

  if 'ssl' in $horizon_bind_options {
    $horizon_options = {
      'cookie'  => 'sessionid prefix',
      'reqadd'  => 'X-Forwarded-Proto:\ https if { ssl_fc }',
      'balance' => 'leastconn'
    }
  } else {
    $horizon_options = {
      'cookie'  => 'sessionid prefix',
      'balance' => 'leastconn'
    }
  }

  cloud::loadbalancer::binding { 'horizon_cluster':
    ip                => $horizon,
    port              => $horizon_port,
    httpchk           => "httpchk GET  /${::cloud::params::horizon_auth_url}  \"HTTP/1.0\\r\\nUser-Agent: HAproxy-${::hostname}\"",
    options           => $horizon_options,
    bind_options      => $horizon_bind_options,
    firewall_settings => $firewall_settings,
  }

  cloud::loadbalancer::binding { 'horizon_ssl_cluster':
    ip                => $horizon_ssl,
    port              => $horizon_ssl_port,
    httpchk           => 'ssl-hello-chk',
    options           => $horizon_ssl_options,
    bind_options      => $horizon_ssl_bind_options,
    firewall_settings => $firewall_settings,
  }

  if (member(any2array($keepalived_public_ipvs), $galera_ip)) {
    warning('Exposing Galera cluster to public network is a security issue.')
  }
  haproxy::listen { 'galera_cluster':
    ipaddress    => $galera_ip,
    ports        => 3306,
    options      => {
      'maxconn'        => '1000',
      'mode'           => 'tcp',
      'balance'        => 'roundrobin',
      'option'         => ['tcpka', 'tcplog', 'httpchk'], #httpchk mandatory expect 200 on port 9000
      'timeout client' => '400s',
      'timeout server' => '400s',
    },
    bind_options => $galera_bind_options,
  }

  if $galera_slave {

    if $::cloud::manage_firewall {
      cloud::firewall::rule{ '100 allow galera-slave binding access':
        port   => '3307',
        extras => $firewall_settings,
      }
    }

    haproxy::listen { 'galera_readonly_cluster':
      ipaddress    => $galera_ip,
      ports        => 3307,
      options      => {
        'maxconn'        => '1000',
        'mode'           => 'tcp',
        'balance'        => 'roundrobin',
        'option'         => ['tcpka', 'tcplog', 'httpchk'], #httpchk mandatory expect 200 on port 9000
        'timeout client' => '400s',
        'timeout server' => '400s',
      },
      bind_options => $galera_bind_options,
    }
  }

  # Allow HAProxy to bind to a non-local IP address
  $haproxy_sysctl_settings = {
    'net.ipv4.ip_nonlocal_bind' => { value => 1 }
  }
  create_resources(sysctl::value,$haproxy_sysctl_settings)

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow galera binding access':
      port   => '3306',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow haproxy monitor access':
      port   => '9300',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow keepalived access':
      port   => undef,
      proto  => 'vrrp',
      extras => $firewall_settings,
    }
  }

}
