define fluentd::match (
  $configfile,
  $type, 
  $pattern, 
  $config   = {},
  $servers  = [],
  ) {

  concat::fragment { "match_$title":
    target  => "/etc/td-agent/config.d/$configfile.conf",
    require => Package['td-agent'],
    content => template('fluentd/match.erb'),
  }
}