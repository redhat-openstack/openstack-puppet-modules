class properties {

  pacemaker_property { 'stonith-enabled' :
    ensure => 'present',
    value  => false,
  }

  pacemaker_property { 'no-quorum-policy' :
    ensure => 'present',
    value  => 'ignore',
  }

}

include ::properties

class { '::pacemaker::new' :
  cluster_nodes    => ['node'],
  cluster_password => 'hacluster',

  # firewall is not needed on a signle node
  firewall_corosync_manage => false,
  firewall_pcsd_manage     => false,
}

Class['pacemaker::new'] ->
Class['properties']


