define pacemaker::resource::ocf($group='',
                                $clone=false,
                                $interval='30s',
                                $monitor_params=undef,
                                $ensure='present',
                                $options='',
                                $resource_name='') {

  pcmk_resource { "${name}":
    ensure          => $ensure,
    resource_type   => "ocf:${resource_name}",
    resource_params => $options,
    group           => $group,
    clone           => $clone,
    interval        => $interval,
    monitor_params  => $monitor_params,
  }

}
