define fluentd::match (
  $type, 
  $format, 
  $config = [],
  ) {

  concat::fragment { 'match':
    target  => "/etc/td-agent/config.d/match.conf",
    require => Package['td-agent'],
    content => template('fluentd/match.erb'),
  }
}