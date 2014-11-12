define pacemaker::resource::lsb($group='',
                                $clone=false,
                                $interval='30s',
                                $ensure='present') {

  pcmk_resource { "lsb-${name}":
    ensure          => $ensure,
    resource_type   => "lsb:${name}",
    resource_params => '',
    group           => $group,
    clone           => $clone,
    interval        => $interval,
  }

}
