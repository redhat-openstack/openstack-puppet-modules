# Class: zookeeper::service

class zookeeper::service(
  $cfg_dir = '/etc/zookeeper/conf',
  $service_name = 'zookeeper',
){
  require zookeeper::install

  service { 'zookeeper':
    name       => "$service_name",
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [
      Class['zookeeper::install'],
      File["${cfg_dir}/zoo.cfg"]
    ]
  }
}
