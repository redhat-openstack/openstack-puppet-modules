# Install and configure the optional DataStax agent.
class cassandra::datastax_agent (
  $defaults_file   = '/etc/default/datastax-agent',
  $java_home       = undef,
  $package_ensure  = 'present',
  $package_name    = 'datastax-agent',
  $service_ensure  = 'running',
  $service_enable  = true,
  $service_name    = 'datastax-agent',
  $stomp_interface = undef,
  ){
  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra'],
    notify  => Service[$service_name]
  }

  if $stomp_interface != undef {
    $ensure = present
  } else {
    $ensure = absent
  }

  ini_setting { 'stomp_interface':
    ensure            => $ensure,
    path              => '/var/lib/datastax-agent/conf/address.yaml',
    section           => '',
    key_val_separator => ': ',
    setting           => 'stomp_interface',
    value             => $stomp_interface,
    require           => Package[$package_name],
    notify            => Service[$service_name]
  }

  if $java_home != undef {
    ini_setting { 'java_home':
      ensure            => present,
      path              => $defaults_file,
      section           => '',
      key_val_separator => '=',
      setting           => 'JAVA_HOME',
      value             => $java_home,
      notify            => Service[$service_name]
    }
  }

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enable,
  }
}
