define fluentd::source (
  $configfile,
  $type, 
  $tag      = false,
  $format   = false, 
  $config   = {},
  ) {

  concat::fragment { "source_$title":
    target  => "/etc/td-agent/config.d/$configfile.conf",
    require => Package['td-agent'],
    content => template('fluentd/source.erb'),
  }
}