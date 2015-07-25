# cassandra::opscenter::setting
define cassandra::opscenter::setting (
  $path,
  $section,
  $setting,
  $value,
  ) {
  Ini_setting {
    ensure            => present,
    path              => $path,
    section           => $section,
    setting           => $setting,
    key_val_separator => ' = ',
    require           => Package['opscenter'],
    notify            => Service['opscenterd'],
  }

  if $value != undef {
    ini_setting { "${section} ${setting}":
      value  => $value,
    }
  }
}
