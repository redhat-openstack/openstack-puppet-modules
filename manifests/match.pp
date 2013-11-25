define fluentd::match (
  $type, 
  $pattern, 
  $config   = {},
  $servers  = [],
  ) {

  concat::fragment { "match_$title":
    target  => "/etc/td-agent/config.d/$title.conf",
    require => Package['td-agent'],
    content => template('fluentd/match.erb'),
  }
}