define pacemaker::resource::route(
  $ensure             = 'present',
  $src                = '',
  $dest               = '',
  $gateway            = '',
  $nic                = '',
  $clone_params       = undef,
  $group_params       = undef,
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
) {

  $nic_option = $nic ? {
      ''      => '',
      default => " device=${nic}"
  }

  $src_option = $src ? {
      ''      => '',
      default => " source=${src}"
  }

  $dest_option = $dest ? {
      ''      => '',
      default => " destination=${dest}"
  }

  $gw_option = $gateway ? {
      ''      => '',
      default => " gateway=${gateway}"
  }

  pcmk_resource { "route-${name}-${group}":
    ensure             => $ensure,
    resource_type      => 'Route',
    resource_params    => "${dest_option} ${src_option} ${nic_option} ${gw_option}",
    group_params       => $group_params,
    clone_params       => $clone_params,
    post_success_sleep => $post_success_sleep,
    tries              => $tries,
    try_sleep          => $try_sleep,
  }

}
