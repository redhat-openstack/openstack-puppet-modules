# Install and configure the optional DataStax agent.
#
# @example when declaring the class
#   include cassandra::datastax_agent
#
# @param package_ensure Is passed to the package reference (default 'present')
class cassandra::datastax_agent (
  $package_ensure = 'present',
  $package_name   = 'datastax-agent',
  $service_ensure = 'running',
  $service_enable = true,
  $service_name   = 'datastax-agent'
  ){
  package { $package_name:
    ensure => $package_ensure
  }

  service { $service_name:
    ensure  => $service_ensure,
    enable  => $service_enable,
    require => Package[$package_name],
  }
}
