# Class: zookeeper::service

class zookeeper::service{

  require zookeeper::install

  service { 'zookeeper':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Package['zookeeperd'],
  }
}