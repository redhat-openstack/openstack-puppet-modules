# Copyright 2016 Red Hat, Inc.
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
# == Class: tripleo::profile::pacemaker::keystone
#
# Keystone Pacemaker HA profile for tripleo
#
# === Parameters
#
# [*bootstrap_node*]
#   (Optional) The hostname of the node responsible for bootstrapping tasks
#   Defaults to hiera('bootstrap_nodeid')
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
# [*enable_load_balancer*]
#   (Optional) Whether load balancing is enabled for this cluster
#   Defaults to hiera('enable_load_balancer', true)
#
class tripleo::profile::pacemaker::keystone (
  $bootstrap_node       = hiera('bootstrap_nodeid'),
  $step                 = hiera('step'),
  $enable_load_balancer = hiera('enable_load_balancer', true)
) {

  if $::hostname == downcase($bootstrap_node) {
    $pacemaker_master = true
  } else {
    $pacemaker_master = false
  }

  if $step >= 6 and $pacemaker_master {
    $manage_roles = true
    Pacemaker::Resource::Service[$::apache::params::service_name] -> Class['::keystone::roles::admin']
    Pacemaker::Resource::Service[$::apache::params::service_name] -> Class['::keystone::endpoint']
  } else {
    $manage_roles = false
  }

  if $step >= 4 {
    class { '::tripleo::profile::base::keystone':
      sync_db          => $pacemaker_master,
      manage_service   => false,
      enabled          => false,
      bootstrap_master => $pacemaker_master,
      manage_roles     => $manage_roles,
      manage_endpoint  => $manage_roles
    }
  }

  if $step >= 5 and $pacemaker_master and $enable_load_balancer {
    pacemaker::constraint::base { 'haproxy-then-keystone-constraint':
      constraint_type => 'order',
      first_resource  => 'haproxy-clone',
      second_resource => 'openstack-core-clone',
      first_action    => 'start',
      second_action   => 'start',
      require         => [Pacemaker::Resource::Service['haproxy'],
                          Pacemaker::Resource::Ocf['openstack-core']],
    }
  }

  if $step >= 5 and $pacemaker_master {
    pacemaker::constraint::base { 'rabbitmq-then-keystone-constraint':
      constraint_type => 'order',
      first_resource  => 'rabbitmq-clone',
      second_resource => 'openstack-core-clone',
      first_action    => 'start',
      second_action   => 'start',
      require         => [Pacemaker::Resource::Ocf['rabbitmq'],
                          Pacemaker::Resource::Ocf['openstack-core']],
    }
  }
}
