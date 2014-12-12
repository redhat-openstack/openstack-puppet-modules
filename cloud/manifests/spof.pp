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
# == Class: cloud::spof
#
# Install all SPOF services in active / passive with Pacemaker / Corosync
#
# === Parameters:
#
# [*cluster_ip*]
#   (optional) Interface used by Corosync to send multicast traffic
#   Defaults to '127.0.0.1'
# [*cluster_members*]
#   (required on Red Hat) A space-separted list of cluster IP's or names
#   Defaults to false
#
# [*multicast_address*]
#   (optionnal) IP address used to send multicast traffic
#   Defaults to '239.1.1.2'
#
# [*firewall_settings*]
#   (optional) Allow to add custom parameters to firewall rules
#   Should be an hash.
#   Default to {}
#
# [*cluster_password*]
#   (optionnal) Password of the pacemaker cluster
#   Defaults to 'secrete'
#
class cloud::spof(
  $cluster_ip        = '127.0.0.1',
  $cluster_members   = false,
  $multicast_address = '239.1.1.2',
  $cluster_password  = 'secrete',
  $firewall_settings = {},
) {

  if $::osfamily == 'RedHat' {
    if ! $cluster_members {
      fail('cluster_members is a required parameter.')
    }

    class { 'pacemaker':
      hacluster_pwd => $cluster_password
    }
    class { 'pacemaker::corosync':
      cluster_name     => 'openstack',
      cluster_members  => $cluster_members,
      settle_timeout   => 10,
      settle_tries     => 2,
      settle_try_sleep => 5,
      manage_fw        => false
    }
    class {'pacemaker::stonith':
      disable => true
    }
    file { '/usr/lib/ocf/resource.d/heartbeat/ceilometer-agent-central':
      source => 'puppet:///modules/cloud/heartbeat/ceilometer-agent-central',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    } ->
    exec {'pcmk_ceilometer_agent_central':
      command => 'pcs resource create ceilometer-agent-central ocf:heartbeat:ceilometer-agent-central',
      path    => ['/usr/bin','/usr/sbin','/sbin/','/bin'],
      user    => 'root',
      unless  => '/usr/sbin/pcs resource | /bin/grep ceilometer-agent-central | /bin/grep Started'
    }
  } else {

    class { 'corosync':
      enable_secauth    => false,
      authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
      bind_address      => $cluster_ip,
      multicast_address => $multicast_address
    }

    corosync::service { 'pacemaker':
      version => '0',
    }

    Package['corosync'] ->
    cs_property {
      'no-quorum-policy':         value => 'ignore';
      'stonith-enabled':          value => 'false';
      'pe-warn-series-max':       value => 1000;
      'pe-input-series-max':      value => 1000;
      'cluster-recheck-interval': value => '5min';
    } ->
    file { '/usr/lib/ocf/resource.d/heartbeat/ceilometer-agent-central':
      source => 'puppet:///modules/cloud/heartbeat/ceilometer-agent-central',
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    } ->
    cs_primitive { 'ceilometer-agent-central':
      primitive_class => 'ocf',
      primitive_type  => 'ceilometer-agent-central',
      provided_by     => 'heartbeat',
      operations      => {
        'monitor' => {
          interval => '10s',
          timeout  => '30s'
        },
        'start'   => {
          interval => '0',
          timeout  => '30s',
          on-fail  => 'restart'
        }
      }
    } ->
    exec { 'cleanup_ceilometer_agent_central':
      command => 'crm resource cleanup ceilometer-agent-central',
      unless  => 'crm resource show ceilometer-agent-central | grep Started',
      user    => 'root',
      path    => ['/usr/sbin', '/bin'],
    }
  }


  # Run OpenStack SPOF service and disable them since they will be managed by Corosync.
  class { 'cloud::telemetry::centralagent':
    enabled => false,
  }

  if $::cloud::manage_firewall {
    cloud::firewall::rule{ '100 allow vrrp access':
      port   => undef,
      proto  => 'vrrp',
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow corosync tcp access':
      port   => ['2224','3121','21064'],
      extras => $firewall_settings,
    }
    cloud::firewall::rule{ '100 allow corosync udp access':
      port   => ['5404','5405'],
      proto  => 'udp',
      extras => $firewall_settings,
    }
  }

}
