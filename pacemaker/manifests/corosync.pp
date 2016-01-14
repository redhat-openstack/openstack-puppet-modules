# == Class: pacemaker::corosync
#
# A class to setup a pacemaker cluster
#
# === Parameters
# [*cluster_name*]
#   The name of the cluster (no whitespace)
# [*cluster_members*]
#   A space-separted list of cluster IP's or names to run the authentication against
# [*cluster_members_rrp*]
#   A space-separated list of cluster IP's or names pair where each component represent a resource on respectively ring0 and ring1
# [*setup_cluster*]
#   If your cluster includes pcsd, this should be set to true for just
#    one node in cluster.  Else set to true for all nodes.
# [*manage_fw*]
#   Manage or not IPtables rules.
# [*settle_timeout*]
#   Timeout to wait for settle.
# [*settle_tries*]
#   Number of tries for settle.
# [*settle_try_sleep*]
#   Time to sleep after each seetle try.
# [*remote_authkey*]
#   Value of /etc/pacemaker/authkey.  Useful for pacemaker_remote.
# [*cluster_setup_extras*]
#   Hash additional configuration when pcs cluster setup is run
#   Example : {'--token' => '10000', '--ipv6' => '', '--join' => '100' }


class pacemaker::corosync(
  $cluster_members,
  $cluster_members_rrp  = undef,
  $cluster_name         = 'clustername',
  $setup_cluster        = true,
  $manage_fw            = true,
  $settle_timeout       = '3600',
  $settle_tries         = '360',
  $settle_try_sleep     = '10',
  $remote_authkey       = undef,
  $cluster_setup_extras = {},
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

  if $pcsd_mode {
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
    Service['pcsd'] ->
    # we have more fragile when-to-start pacemaker conditions with pcsd
    exec {"enable-not-start-$cluster_name":
      command => "/usr/sbin/pcs cluster enable"
    }
    ->
    exec {"Set password for hacluster user on $cluster_name":
      command => "/bin/echo ${::pacemaker::hacluster_pwd} | /usr/bin/passwd --stdin hacluster",
      creates => "/etc/cluster/cluster.conf",
      require => Class["::pacemaker::install"],
    }
    ->
    exec {"auth-successful-across-all-nodes":
      command   => "/usr/sbin/pcs cluster auth $cluster_members -u hacluster -p ${::pacemaker::hacluster_pwd} --force",
      timeout   => $settle_timeout,
      tries     => $settle_tries,
      try_sleep => $settle_try_sleep,
    }
    ->
    Exec["wait-for-settle"]
  }

  if $setup_cluster {

    if ! $cluster_members_rrp {
      $cluster_members_rrp_real = $cluster_members
    } else {
      $cluster_members_rrp_real = $cluster_members_rrp
    }

    $cluster_setup_extras_real = inline_template('<%= @cluster_setup_extras.flatten.join(" ") %>')

    exec {"Create Cluster $cluster_name":
      creates => "/etc/cluster/cluster.conf",
      command => "/usr/sbin/pcs cluster setup --name $cluster_name $cluster_members_rrp_real $cluster_setup_extras_real",
      unless => "/usr/bin/test -f /etc/corosync/corosync.conf",
      require => Class["::pacemaker::install"],
    }
    ->
    exec {"Start Cluster $cluster_name":
      unless => "/usr/sbin/pcs status >/dev/null 2>&1",
      command => "/usr/sbin/pcs cluster start --all",
      require => Exec["Create Cluster $cluster_name"],
    }
    if $pcsd_mode {
      Exec["auth-successful-across-all-nodes"] ->
        Exec["Create Cluster $cluster_name"]
    }
    Exec["Start Cluster $cluster_name"] ->
      Exec["wait-for-settle"]
  }

  if $remote_authkey {
    file { 'etc-pacemaker':
      ensure => directory,
      path    => '/etc/pacemaker',
      owner   => 'hacluster',
      group   => 'haclient',
      mode    => '0750',
    } ->
    file { 'etc-pacemaker-authkey':
      path    => '/etc/pacemaker/authkey',
      owner   => 'hacluster',
      group   => 'haclient',
      mode    => '0640',
      content => $remote_authkey,
    }
    if $setup_cluster {
      File['etc-pacemaker-authkey'] -> Exec["Create Cluster $cluster_name"]
    }
    if $pcsd_mode {
      File['etc-pacemaker-authkey'] -> Service['pcsd']
    }
  }

  exec {"wait-for-settle":
    timeout   => $settle_timeout,
    tries     => $settle_tries,
    try_sleep => $settle_try_sleep,
    command   => "/usr/sbin/pcs status | grep -q 'partition with quorum' > /dev/null 2>&1",
    unless    => "/usr/sbin/pcs status | grep -q 'partition with quorum' > /dev/null 2>&1",
    notify    => Notify["pacemaker settled"],
  }

  notify {"pacemaker settled":
    message => "Pacemaker has reported quorum achieved",
  }
}
