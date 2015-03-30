define pacemaker::resource::route($src='',
                               $dest='',
                               $gateway='',
                               $nic='',
                               $clone= false,
                               $group='',
                               $interval='30s',
                               $monitor_params=undef,
                               $ensure='present') {

  $nic_option = $nic ? {
      ''      => '',
      default => " device=$nic"
  }

  $src_option = $src ? {
      ''      => '',
      default => " source=$src"
  }

  $dest_option = $dest ? {
      ''      => '',
      default => " destination=$dest"
  }

  $gw_option = $gateway ? {
      ''      => '',
      default => " gateway=$gateway"
  }

  pcmk_resource { "route-${name}-${group}":
    ensure          => $ensure,
    resource_type   => 'Route',
    resource_params => "${dest_option} ${src_option} ${nic_option} ${gw_option}",
    group           => $group,
    interval        => $interval,
    monitor_params  => $monitor_params,
    clone           => $clone,
  }

}
