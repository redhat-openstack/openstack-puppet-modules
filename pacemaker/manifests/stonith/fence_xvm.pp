# To use this class ensure that fence_virtd is properly configured and running on the hypervisor

class pacemaker::stonith::fence_xvm(
  $name,
  $manage_key_file=false,
  $key_file="/etc/cluster/fence_xvm.key",
  $key_file_password="123456",
  $interval="30s",
  $ensure=present,
  $port=undef,       # the name of the vm
  $pcmk_host=undef,  # the hostname or IP that pacemaker uses
  ) {
  if($ensure == absent) {
    exec { "Removing stonith::fence_xvm ${name}":
      command => "/usr/sbin/pcs stonith delete fence_xvm-${name }",
      onlyif  => "/usr/sbin/pcs stonith show fence_xvm-${name} > /dev/null 2>&1",
      require => Class['pacemaker::corosync'],
    }
  } else {
    $port_chunk = $port ? {
      ''      => '',
      default => "port=${port}",
    }
    $pcmk_host_list_chunk = $pcmk_host ? {
      ''      => '',
      default => "pcmk_host_list=${pcmk_host}",
    }
    if $manage_key_file {
      file { "$key_file":
        content => "$key_file_password",
      }
    }
    firewall { "003 fence_xvm":
      proto    => 'igmp',
      action   => 'accept',
    }
    firewall { "004 fence_xvm":
      proto    => 'udp',
      dport     => '1229',
      action   => 'accept',
    }
    firewall { "005 fence_xvm":
      proto    => 'tcp',
      dport     => '1229',
      action   => 'accept',
    }

    exec { "Creating stonith::fence_xvm ${name}":
      command => "/usr/sbin/pcs stonith create fence_xvm-${name} fence_xvm ${port_chunk} ${pcmk_host_list_chunk} op monitor interval=${interval}",
      unless  => "/usr/sbin/pcs stonith show fence_xvm-${name}  > /dev/null 2>&1",
      require => Class['pacemaker::corosync'],
    }
  }
}
