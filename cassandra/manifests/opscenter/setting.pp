# cassandra::opscenter::setting
define cassandra::opscenter::setting (
  $path,
  $section,
  $setting,
  $value   = undef,
  ) {
  if $value != undef {
    ini_setting { "${section} ${setting}":
      path              => $path,
      section           => $section,
      setting           => $setting,
      key_val_separator => ' = ',
      require           => Package['opscenter'],
      notify            => Service['opscenterd'],
      value             => $value,
    }
  } else {
    ini_setting { "${section} ${setting}":
      ensure            => absent,
      path              => $path,
      section           => $section,
      setting           => $setting,
      key_val_separator => ' = ',
      require           => Package['opscenter'],
      notify            => Service['opscenterd'],
    }
  }
}
