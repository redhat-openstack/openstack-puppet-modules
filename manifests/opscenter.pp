# Install and configure DataStax OpsCenter
#
# See the module README for details on how to use.
class cassandra::opscenter (
    $authentication_enabled = 'False',
    $ensure                 = present,
    $config_file            = '/etc/opscenter/opscenterd.conf',
    $interface              = '0.0.0.0',
    $package_name           = 'opscenter',
    $port                   = 8888,
    $service_enable         = true,
    $service_ensure         = 'running',
    $service_name           = 'opscenterd',
  ) {
  package { 'opscenter':
    ensure  => $ensure,
    name    => $package_name,
    require => Class['cassandra'],
    before  => Service[$service_name]
  }

  ini_setting { 'authentication_enabled':
    ensure            => present,
    path              => $config_file,
    section           => 'authentication',
    setting           => 'enabled',
    value             => $authentication_enabled,
    require           => Package['opscenter'],
    key_val_separator => ' = ',
    notify            => Service[$service_name],
  }

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
