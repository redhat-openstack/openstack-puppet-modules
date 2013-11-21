class fluentd {
  include packages

  file { '/etc/td-agent/config.d':
    ensure => "directory",
    owner  => "root",
    group  => "root",
    mode   => 750,
    require => Package['td-agent'],
  }
}