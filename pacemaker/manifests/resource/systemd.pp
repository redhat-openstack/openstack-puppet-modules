define pacemaker::resource::systemd($group='',
                                $clone=false,
                                $interval='30s',
                                $monitor_params=undef,
                                $ensure='present',
                                $options='') {

  pcmk_resource { "${name}":
    ensure          => $ensure,
    resource_type   => "systemd:${name}",
    resource_params => $options,
    group           => $group,
    clone           => $clone,
    interval        => $interval,
    monitor_params  => $monitor_params,
  }

}
