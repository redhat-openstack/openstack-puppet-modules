# cassandra::opscenter::setting
define cassandra::opscenter::setting (
  $service_name,
  $path,
  $section,
  $setting,
  $value,
  ) {
  if value != undef {
    ini_setting { "${section}:${setting}":
      ensure            => present,
      path              => $path,
      section           => $section,
      setting           => $setting,
      value             => $value,
      key_val_separator => ' = ',
      require           => Package['opscenter'],
      notify            => Service[$service_name],
    }
  }
}
