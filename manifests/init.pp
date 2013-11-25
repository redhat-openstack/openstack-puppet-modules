class fluentd {
  include packages


  file { '/etc/td-agent/td-agent.conf' :
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    source  => 'puppet:///modules/fluentd/etc/fluentd/td-agent.conf',
    require => Package['td-agent'],
    #notify  => Class['fluentd::service'],
  }

  file { '/etc/td-agent/config.d':
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 750,
    require => Package['td-agent'],
  }
}