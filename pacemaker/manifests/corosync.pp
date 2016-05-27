# == Class: pacemaker::corosync
#
# A class to setup a pacemaker cluster
#
# === Parameters
# [*cluster_members*]
#   (required) A space-separted list of cluster IP's or names to run the 
#   authentication against
#
# [*cluster_members_rrp*]
#   (optional) A space-separated list of cluster IP's or names pair where each
#   component represent a resource on respectively ring0 and ring1
#   Defaults to undef
#
# [*cluster_name*]
#   (optional) The name of the cluster (no whitespace)
#   Defaults to 'clustername'
#
# [*cluster_setup_extras*]
#   (optional) Hash additional configuration when pcs cluster setup is run
#   Example : {'--token' => '10000', '--ipv6' => '', '--join' => '100' }
#   Defaults to {}
#
# [*manage_fw*]
#   (optional) Manage or not IPtables rules.
#   Defaults to true
#
# [*remote_authkey*]
#   (optional) Value of /etc/pacemaker/authkey.  Useful for pacemaker_remote.
#   Defaults to undef
#
# [*settle_timeout*]
#   (optional) Timeout to wait for settle.
#   Defaults to 3600
#
# [*settle_tries*]
#   (optional) Number of tries for settle.
#   Defaults to 360
#
# [*settle_try_sleep*]
#   (optional) Time to sleep after each seetle try.
#   Defaults to 10
#
# [*setup_cluster*]
#   (optional) If your cluster includes pcsd, this should be set to true for
#   just one node in cluster.  Else set to true for all nodes.
#   Defaults to true
#
# === Dependencies
#
#  None
#
# === Authors
#
#  Crag Wolfe <cwolfe@redhat.com>
#  Jason Guiditta <jguiditt@redhat.com>
#
# === Copyright
#
# Copyright (C) 2016 Red Hat Inc.
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
class pacemaker::corosync(
  $cluster_members,
  $cluster_members_rrp  = undef,
  $cluster_name         = 'clustername',
  $cluster_setup_extras = {},
  $manage_fw            = true,
  $remote_authkey       = undef,
  $settle_timeout       = '3600',
  $settle_tries         = '360',
  $settle_try_sleep     = '10',
  $setup_cluster        = true,
) inherits pacemaker {
  include ::pacemaker::params

  if $manage_fw {
    firewall { '001 corosync mcast':
      proto  => 'udp',
      dport  => ['5404', '5405'],
      action => 'accept',
    }
    firewall { '001 corosync mcast ipv6':
      proto    => 'udp',
      dport    => ['5404', '5405'],
      action   => 'accept',
      provider => 'ip6tables',
    }
  }

  if $pacemaker::pcsd_mode {
    if $manage_fw {
      firewall { '001 pcsd':
        proto  => 'tcp',
        dport  => ['2224'],
        action => 'accept',
      }
      firewall { '001 pcsd ipv6':
        proto    => 'tcp',
        dport    => ['2224'],
        action   => 'accept',
        provider => 'ip6tables',
      }
    }
    user { 'hacluster':
      password => pw_hash($::pacemaker::hacluster_pwd, 'SHA-512', fqdn_rand_string(10)),
      groups   => 'haclient',
      require  => Class['::pacemaker::install'],
      notify   => Exec['reauthenticate-across-all-nodes'],
    }

    exec { 'reauthenticate-across-all-nodes':
      command     => "${::pacemaker::pcs_bin} cluster auth ${cluster_members} -u hacluster -p ${::pacemaker::hacluster_pwd} --force",
      refreshonly => true,
      timeout     => $settle_timeout,
      tries       => $settle_tries,
      try_sleep   => $settle_try_sleep,
      tag         => 'pacemaker-auth',
    }

    Service['pcsd'] ->
    exec { 'auth-successful-across-all-nodes':
      command     => "${::pacemaker::pcs_bin} cluster auth ${cluster_members} -u hacluster -p ${::pacemaker::hacluster_pwd}",
      refreshonly => true,
      timeout     => $settle_timeout,
      tries       => $settle_tries,
      try_sleep   => $settle_try_sleep,
      require     => User['hacluster'],
      unless      => "${::pacemaker::pcs_bin} cluster auth ${cluster_members} -u hacluster -p ${::pacemaker::hacluster_pwd} | grep 'Already authorized'",
      tag         => 'pacemaker-auth',
    }

    Exec <|tag == 'pacemaker-auth'|> -> Exec['wait-for-settle']
  }

  if $setup_cluster {

    if ! $cluster_members_rrp {
      $cluster_members_rrp_real = $cluster_members
    } else {
      $cluster_members_rrp_real = $cluster_members_rrp
    }

    $cluster_setup_extras_real = inline_template('<%= @cluster_setup_extras.flatten.join(" ") %>')
    Exec <|tag == 'pacemaker-auth'|>
    ->
    exec {"Create Cluster ${cluster_name}":
      creates => '/etc/cluster/cluster.conf',
      command => "${::pacemaker::pcs_bin} cluster setup --name ${cluster_name} ${cluster_members_rrp_real} ${cluster_setup_extras_real}",
      unless  => '/usr/bin/test -f /etc/corosync/corosync.conf',
      require => Class['::pacemaker::install'],
    }
    ->
    exec {"Start Cluster ${cluster_name}":
      unless  => "${::pacemaker::pcs_bin} status >/dev/null 2>&1",
      command => "${::pacemaker::pcs_bin} cluster start --all",
      require => Exec["Create Cluster ${cluster_name}"],
    }
    if $pacemaker::pcsd_mode {
      Exec['auth-successful-across-all-nodes'] ->
        Exec["Create Cluster ${cluster_name}"]
    }
    Exec["Start Cluster ${cluster_name}"]
    ->
    Service <| tag == 'pcsd-cluster-service' |>
    ->
    Exec['wait-for-settle']
  }

  if $remote_authkey {
    file { 'etc-pacemaker':
      ensure => directory,
      path   => '/etc/pacemaker',
      owner  => 'hacluster',
      group  => 'haclient',
      mode   => '0750',
    } ->
    file { 'etc-pacemaker-authkey':
      path    => '/etc/pacemaker/authkey',
      owner   => 'hacluster',
      group   => 'haclient',
      mode    => '0640',
      content => $remote_authkey,
    }
    if $setup_cluster {
      File['etc-pacemaker-authkey'] -> Exec["Create Cluster ${cluster_name}"]
    }
    if $pacemaker::pcsd_mode {
      File['etc-pacemaker-authkey'] -> Service['pcsd']
    }
  }

  exec {'wait-for-settle':
    timeout   => $settle_timeout,
    tries     => $settle_tries,
    try_sleep => $settle_try_sleep,
    command   => "${::pacemaker::pcs_bin} status | grep -q 'partition with quorum' > /dev/null 2>&1",
    unless    => "${::pacemaker::pcs_bin} status | grep -q 'partition with quorum' > /dev/null 2>&1",
  }

}
