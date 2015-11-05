# == Class zookeeper::params
#
class zookeeper::params {
  $client_port            = 2181
  $zookeeper_start_binary = '/usr/bin/zookeeper-server' # managed by zookeeper-server RPM, do not change unless you
                                                        # are certain that your RPM uses a different path
  # Because $command relies on the $zookeeper_start_binary variable, it must be defined AFTER $zookeeper_start_binary.
  $command                = "${zookeeper_start_binary} start-foreground"
  $config                 = '/etc/zookeeper/conf/zoo.cfg' # managed by zookeeper-server RPM, do not change unless you
                                                          # are certain that your RPM uses a different path
  $config_map             = {
                              'autopurge.purgeInterval'   => 24,
                              'autopurge.snapRetainCount' => 5,
                              'initLimit'                 => 10,
                              'maxClientCnxns'            => 50,
                              'syncLimit'                 => 5,
                              'tickTime'                  => 2000,
                            }
  $config_template        = 'zookeeper/zoo.cfg.erb'
  $data_dir               = '/var/lib/zookeeper'
  # Because $dataLogDir relies on $data_dir, it must be defined AFTER $data_dir.
  $data_log_dir           = $data_dir
  $group                  = 'zookeeper' # managed by zookeeper-server RPM, do not change unless you are certain that
                                        # your RPM uses a different group
  $myid                   = 1
  $package_name           = 'zookeeper-server'
  $package_ensure         = 'present'
  # If you want to use a quorum (normally 3 or 5 members), set this variable to e.g.
  # ['server.1=zookeeper1:2888:3888', 'server.2=zookeeper2:2888:3888', ...] where 'server.<X>' corresponds to a
  # machine's 'zookeeper::myid'.
  $quorum                 = []
  $service_autorestart    = true
  $service_enable         = true
  $service_ensure         = 'present'
  $service_manage         = true
  $service_name           = 'zookeeper'
  $service_retries        = 999
  $service_startsecs      = 10
  $service_stderr_logfile_keep    = 10
  $service_stderr_logfile_maxsize = '20MB'
  $service_stdout_logfile_keep    = 5
  $service_stdout_logfile_maxsize = '20MB'
  $service_stopasgroup    = true
  $service_stopsignal     = 'INT'
  $user                   = 'zookeeper' # managed by zookeeper-server RPM, do not change unless you are certain that
                                        # your RPM uses a different user
  case $::osfamily {
    'RedHat': {}

    default: {
      fail("The ${module_name} module is not supported on a ${::osfamily} based system.")
    }
  }
}
