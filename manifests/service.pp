# Class: zookeeper::service

class zookeeper::service{

  service { 'zookeeper':
    ensure  => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable  => true,
  }
}