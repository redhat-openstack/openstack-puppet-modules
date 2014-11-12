define pacemaker::resource::filesystem($device,
                                       $directory,
                                       $fsoptions='',
                                       $fstype,
                                       $group='',
                                       $clone=false,
                                       $interval='30s',
                                       $ensure='present') {
  $resource_id = delete("fs-${directory}", '/')

  $resource_params = $fsoptions ? {
    ''      => "device=${device} directory=${directory} fstype=${fstype}",
    default => "device=${device} directory=${directory} fstype=${fstype} options=\"${fsoptions}\"",
  }

  pcmk_resource { $resource_id:
    resource_type   => 'Filesystem',
    resource_params => $resource_params,
    group           => $group,
    clone           => $clone,
    interval        => $interval,
    ensure          => $ensure,
  }
}
