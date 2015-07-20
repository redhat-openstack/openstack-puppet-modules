# cassandra::opscenter::setting
define cassandra::opscenter::setting (
  $service_name,
  $path,
  $section,
  $setting,
  $value,
  ) {
  $setting_name = "${section}::${setting}"

  if value != undef {
    ini_setting { $setting_name:
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
