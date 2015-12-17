define fluentd::config($config) {
  $path = sprintf('/etc/td-agent/config.d/%s', $title)

  file { $path:
    ensure  => present,
    content => fluent_config($config),
    require => Class['Fluentd::Install'],
    notify  => Class['Fluentd::Service'],
  }
}
