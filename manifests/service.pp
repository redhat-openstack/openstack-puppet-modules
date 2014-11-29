# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper/conf',
){
  require zookeeper::install

  service { 'zookeeper':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Anchor['zookeeper::install::end'],
      File["${cfg_dir}/zoo.cfg"]
    ]
  }
}