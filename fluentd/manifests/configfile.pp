# == definition fluentd::configfile
define fluentd::configfile(
  $ensure   = present,
  $content,
  $priority = 50,
) {
  $base_name     = "${name}.conf"
  $conf_name     = "${priority}-${base_name}"
  $conf_path     = "/etc/${fluentd::product_name}/config.d/${conf_name}"
  $wildcard_path = "/etc/${fluentd::product_name}/config.d/*-${base_name}"

  # clean up in case of a priority change
  exec { "rm ${wildcard_path}":
    onlyif => "test \$(ls ${wildcard_path} | grep -v ${conf_name} | wc -l) -gt 0",
    path   => ['/usr/bin', '/usr/sbin', '/bin'],
    before => File[$conf_path],
    notify => Class['fluentd::service'],
  }

  if $ensure == 'absent' {
    file { $conf_path:
      ensure  => $ensure,
      notify  => Class['fluentd::service'],
    }
  } else {
    file { $conf_path:
      ensure  => $ensure,
      content => $content,
      owner   => "${fluentd::product_name}",
      group   => "${fluentd::product_name}",
      mode    => '0644',
      require => Class['fluentd::packages'],
      notify  => Class['fluentd::service'],
    }
  }
}
