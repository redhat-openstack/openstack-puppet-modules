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
# == Class: cloud::dashboard
#
# Installs the OpenStack Dashboard (Horizon)
#
# === Parameters:
#
# [*ks_keystone_internal_host*]
#   (optional) Internal address for endpoint.
#   Defaults to '127.0.0.1'
#
# [*secret_key*]
#   (optional) Secret key. This is used by Django to provide cryptographic
#   signing, and should be set to a unique, unpredictable value.
#   Defaults to 'secrete'
#
# [*horizon_port*]
#   (optional) Port used to connect to OpenStack Dashboard
#   Defaults to '80'
#
# [*horizon_ssl_port*]
#   (optional) Port used to connect to OpenStack Dashboard using SSL
#   Defaults to '443'
#
# [*api_eth*]
#   (optional) Which interface we bind the Horizon server.
#   Defaults to '127.0.0.1'
#
# [*servername*]
#   (optional) DNS name used to connect to Openstack Dashboard.
#   Default value fqdn.
#
# [*listen_ssl*]
#   (optional) Enable SSL on OpenStack Dashboard vhost
#   It requires SSL files (keys and certificates)
#   Defaults false
#
# [*keystone_proto*]
#   (optional) Protocol (http or https) of keystone endpoint.
#   Defaults to 'http'
#
# [*keystone_host*]
#   (optional) IP / Host of keystone endpoint.
#   Defaults '127.0.0.1'
#
# [*keystone_port*]
#   (optional) TCP port of keystone endpoint.
#   Defaults to '5000'
#
# [*debug*]
#   (optional) Enable debug or not.
#   Defaults to true
#
# [*horizon_cert*]
#   (required with listen_ssl) Certificate to use for SSL support.
#
# [*horizon_key*]
#   (required with listen_ssl) Private key to use for SSL support.
#
# [*horizon_ca*]
#   (required with listen_ssl) CA certificate to use for SSL support.
#
# [*ssl_forward*]
#   (optional) Forward HTTPS proto in the headers
#   Useful when activating SSL binding on HAproxy and not in Horizon.
#   Defaults to false
#
#  [*os_endpoint_type*]
#    (optional) endpoint type to use for the endpoints in the Keystone
#    service catalog. Defaults to 'undef'.
#
#  [*allowed_hosts*]
#    (optional) List of hosts which will be set as value of ALLOWED_HOSTS
#    parameter in settings_local.py. This is used by Django for
#    security reasons. Can be set to * in environments where security is
#    deemed unimportant.
#    Defaults to ::fqdn.
#
#  [*vhost_extra_params*]
#    (optionnal) extra parameter to pass to the apache::vhost class
#    Defaults to {}
#
# [*neutron_extra_options*]
#   (optional) Enable optional services provided by neutron
#   Useful when using cisco n1kv plugin, vpnaas or fwaas.
#   Default to {}
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::dashboard(
  $ks_keystone_internal_host = '127.0.0.1',
  $secret_key                = 'secrete',
  $horizon_port              = 80,
  $horizon_ssl_port          = 443,
  $servername                = $::fqdn,
  $api_eth                   = '127.0.0.1',
  $keystone_host             = '127.0.0.1',
  $keystone_proto            = 'http',
  $keystone_port             = 5000,
  $debug                     = true,
  $listen_ssl                = false,
  $horizon_cert              = undef,
  $horizon_key               = undef,
  $horizon_ca                = undef,
  $ssl_forward               = false,
  $os_endpoint_type          = undef,
  $allowed_hosts             = $::fqdn,
  $vhost_extra_params        = {},
  $neutron_extra_options     = {},
  $firewall_settings         = {},
) {

  # We build the param needed for horizon class
  $keystone_url = "${keystone_proto}://${keystone_host}:${keystone_port}/v2.0"

  # Apache2 specific configuration
  if $ssl_forward {
    $setenvif = ['X-Forwarded-Proto https HTTPS=1']
  } else {
    $setenvif = []
  }
  $extra_params = {
    'add_listen' => true,
    'setenvif'   => $setenvif
  }
  $vhost_extra_params_real = merge ($extra_params, $vhost_extra_params)

  $neutron_options = {
    'enable_lb' => true
  }
  $neutron_options_real = merge ($neutron_options, $neutron_extra_options)

  ensure_resource('class', 'apache', {
    default_vhost => false
  })

  class { 'horizon':
    secret_key              => $secret_key,
    can_set_mount_point     => 'False',
    servername              => $servername,
    bind_address            => $api_eth,
    swift                   => true,
    keystone_url            => $keystone_url,
    cache_server_ip         => false,
    django_debug            => $debug,
    neutron_options         => $neutron_options_real,
    listen_ssl              => $listen_ssl,
    horizon_cert            => $horizon_cert,
    horizon_key             => $horizon_key,
    horizon_ca              => $horizon_ca,
    vhost_extra_params      => $vhost_extra_params_real,
    openstack_endpoint_type => $os_endpoint_type,
    allowed_hosts           => $allowed_hosts,
  }

  if ($::osfamily == 'Debian') {
    # TODO(Goneri): HACK to ensure Horizon can cache its files
    $horizon_var_dir = ['/var/lib/openstack-dashboard/static/js','/var/lib/openstack-dashboard/static/css']
    file {$horizon_var_dir:
      ensure => directory,
      owner  => 'horizon',
      group  => 'horizon',
    }
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow horizon access':
      port   => $horizon_port,
      extras => $firewall_settings,
    }
  }

  @@haproxy::balancermember{"${::fqdn}-horizon":
    listening_service => 'horizon_cluster',
    server_names      => $::hostname,
    ipaddresses       => $api_eth,
    ports             => $horizon_port,
    options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
  }

  if $listen_ssl {

    if $::cloud::manage_firewall {
      cloud::firewall::rule{ '100 allow horizon ssl access':
        port   => $horizon_ssl_port,
        extras => $firewall_settings,
      }
    }

    @@haproxy::balancermember{"${::fqdn}-horizon-ssl":
      listening_service => 'horizon_ssl_cluster',
      server_names      => $::hostname,
      ipaddresses       => $api_eth,
      ports             => $horizon_ssl_port,
      options           => "check inter 2000 rise 2 fall 5 cookie ${::hostname}"
    }

  }

}
