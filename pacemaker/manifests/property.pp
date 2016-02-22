define pacemaker::property (
  $property,
  $value     = undef,
  $node      = undef,
  $force     = false,
  $ensure    = present,
  $tries     = 1,
  $try_sleep = 10,
) {
  if $property == undef {
    fail('Must provide property')
  }
  if ($ensure == 'present') and $value == undef {
    fail('When present, must provide value')
  }

  # Special-casing node branches due to https://bugzilla.redhat.com/show_bug.cgi?id=1302010
  # (Basically pcs property show <property> will show all node properties anyway)
  if $node {
    if $ensure == absent {
      exec { "Removing node-property ${property} on ${node}":
        command   => "/usr/sbin/pcs property unset --node ${node} ${property}",
        onlyif    => "/usr/sbin/pcs property show | grep ${property}= | grep ${node}",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    } else {
      if $force {
        $cmd = "/usr/sbin/pcs property set --force --node ${node} ${property}=${value}"
      } else {
        $cmd = "/usr/sbin/pcs property set --node ${node} ${property}=${value}"
      }
      exec { "Creating node-property ${property} on ${node}":
        command   => $cmd,
        unless    => "/usr/sbin/pcs property show ${property} | grep \"${property}=${value}\" | grep ${node}",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    }
  } else {
    if $ensure == absent {
      exec { "Removing cluster-wide property ${property}":
        command   => "/usr/sbin/pcs property unset ${property}",
        onlyif    => "/usr/sbin/pcs property show | grep ${property}: ",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    } else {
      if $force {
        $cmd = "/usr/sbin/pcs property set --force ${property}=${value}"
      } else {
        $cmd = "/usr/sbin/pcs property set ${property}=${value}"
      }
      exec { "Creating cluster-wide property ${property}":
        command   => $cmd,
        unless    => "/usr/sbin/pcs property show ${property} | grep \"${property}=${value}\"",
        require   => [Exec['wait-for-settle'],
                      Class['::pacemaker::corosync']],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    }
  }
}
