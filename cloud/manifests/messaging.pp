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
# == Class: cloud::messaging
#
# Install Messsaging Server (RabbitMQ)
#
# === Parameters:
#
# [*rabbit_names*]
#   (optional) List of RabbitMQ servers. Should be an array.
#   Defaults to $::hostname
#
# [*rabbit_password*]
#   (optional) Password to connect to OpenStack queues.
#   Defaults to 'rabbitpassword'
#
# [*cluster_node_type*]
#   (optional) Store the queues on the disc or in the RAM.
#   Could be set to 'disk' or 'ram'.
#   Defaults to 'disc'
#
# [*haproxy_binding*]
#   (optional) Enable or not HAproxy binding for load-balancing.
#   Defaults to false
#
# [*rabbitmq_ip*]
#   (optional) IP address of RabbitMQ interface.
#   Required when using HAproxy binding.
#   Defaults to $::ipaddress
#
# [*rabbitmq_port*]
#   (optional) Port of RabbitMQ service.
#   Defaults to '5672'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
class cloud::messaging(
  $cluster_node_type = 'disc',
  $rabbit_names      = $::hostname,
  $rabbit_password   = 'rabbitpassword',
  $haproxy_binding   = false,
  $rabbitmq_ip       = $::ipaddress,
  $rabbitmq_port     = '5672',
  $firewall_settings = {},
){

  # we ensure having an array
  $array_rabbit_names = any2array($rabbit_names)

  Class['rabbitmq'] -> Rabbitmq_vhost <<| |>>
  Class['rabbitmq'] -> Rabbitmq_user <<| |>>
  Class['rabbitmq'] -> Rabbitmq_user_permissions <<| |>>

  # Packaging issue: https://bugzilla.redhat.com/show_bug.cgi?id=1033305
  if $::osfamily == 'RedHat' {
    file {'/usr/sbin/rabbitmq-plugins':
      ensure => link,
      target => '/usr/lib/rabbitmq/bin/rabbitmq-plugins'
    }

    file {'/usr/sbin/rabbitmq-env':
      ensure => link,
      target => '/usr/lib/rabbitmq/bin/rabbitmq-env'
    }
  }

  class { 'rabbitmq':
    delete_guest_user        => true,
    config_cluster           => true,
    cluster_nodes            => $array_rabbit_names,
    wipe_db_on_cookie_change => true,
    cluster_node_type        => $cluster_node_type,
    node_ip_address          => $rabbitmq_ip,
    port                     => $rabbitmq_port,
  }

  rabbitmq_vhost { '/':
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq'],
  }
  rabbitmq_user { ['nova','glance','neutron','cinder','ceilometer','heat','trove']:
    admin    => true,
    password => $rabbit_password,
    provider => 'rabbitmqctl',
    require  => Class['rabbitmq']
  }
  rabbitmq_user_permissions {[
    'nova@/',
    'glance@/',
    'neutron@/',
    'cinder@/',
    'ceilometer@/',
    'heat@/',
    'trove@/',
  ]:
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow rabbitmq access':
      port   => $rabbitmq_port,
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow rabbitmq management access':
      port   => '55672',
      extras => $firewall_settings,
    }
  }

  if $haproxy_binding {
    @@haproxy::balancermember{"${::fqdn}-rabbitmq":
      listening_service => 'rabbitmq_cluster',
      server_names      => $::hostname,
      ipaddresses       => $rabbitmq_ip,
      ports             => $rabbitmq_port,
      options           => 'check inter 5s rise 2 fall 3'
    }
  }

}
