# == Class zookeeper::service
#
class zookeeper::service inherits zookeeper {

  # See also:
  # http://arch.corp.anjuke.com/blog/2012/08/27/use-supervisord-with-storm-and-zookeeper/
  # https://gist.github.com/solar/3898427

  if !($service_ensure in ['present', 'absent']) {
    fail('service_ensure parameter must be "present" or "absent"')
  }

  if $service_manage == true {

    supervisor::service {
      $service_name:
        ensure                 => $service_ensure,
        enable                 => $service_enable,
        command                => $command,
        directory              => '/',
        user                   => $user,
        group                  => $group,
        autorestart            => $service_autorestart,
        startsecs              => $service_startsecs,
        retries                => $service_retries,
        stopsignal             => $service_stopsignal,
        stopasgroup            => $service_stopasgroup,
        stdout_logfile_maxsize => $service_stdout_logfile_maxsize,
        stdout_logfile_keep    => $service_stdout_logfile_keep,
        stderr_logfile_maxsize => $service_stderr_logfile_maxsize,
        stderr_logfile_keep    => $service_stderr_logfile_keep,
        require                => [ Class['zookeeper::config'], Class['::supervisor'] ],
    }

    # Make sure that the init.d script shipped with zookeeper-server is not registered as a system service and that the
    # service itself is not running in any case (because we want to run ZooKeeper via supervisord).
    service { $package_name:
      ensure => 'stopped',
      enable => false,
    }

    $subscribe_real = $is_standalone ? {
      true  => File[$config],
      false => [ File[$config], File['zookeeper-myid'] ],
    }

    if $service_enable == true {
      exec { 'restart-zookeeper':
        command     => "supervisorctl restart ${service_name}",
        path        => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
        user        => 'root',
        refreshonly => true,
        subscribe   => $subscribe_real,
        onlyif      => 'which supervisorctl &>/dev/null',
        require     => [ Class['zookeeper::config'], Class['::supervisor'] ],
      }
    }

  }

}
