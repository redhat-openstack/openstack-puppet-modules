class pacemaker::stonith ($disable=true) {
  if $disable == true {
    exec {"Disable STONITH":
        command => "/usr/sbin/pcs property set stonith-enabled=false",
        unless => "/usr/sbin/pcs property show stonith-enabled | grep 'stonith-enabled: false'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  } else {
    exec {"Enable STONITH":
        command => "/usr/sbin/pcs property set stonith-enabled=true",
        onlyif => "/usr/sbin/pcs property show stonith-enabled | grep 'stonith-enabled: false'",
        require => [ Exec["wait-for-settle"],
                     Class['::pacemaker::corosync']
                   ],
    }
  }
}
