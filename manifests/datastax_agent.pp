# Install and configure the optional DataStax agent.
class cassandra::datastax_agent (
  $package_ensure = 'present',
  $package_name   = 'datastax-agent',
  $service_ensure = 'running',
  $service_enable = true,
  $service_name   = 'datastax-agent'
  ){
  package { $package_name:
    ensure  => $package_ensure,
    require => Class['cassandra']
  }

  service { $service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package[$package_name],
  }
}
