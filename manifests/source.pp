define fluentd::source (
  $type, 
  $format = false, 
  $config = [],
  ) {


  #file { $::name:
  #      path    => "/etc/td-agent/config.d/$::name.conf",
  #      ensure  => file,
  #      require => Package['td-agent'],
  #      content => template("fluentd/source.erb"),
  #}

  concat::fragment { 'sources':
    target  => "/etc/td-agent/config.d/sources.conf",
    require => Package['td-agent'],
    content => template('fluentd/source.erb'),
  }
}