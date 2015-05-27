# == Class: cassandra
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra (
  $cassandra_opt_package_name    = undef,
  $cassandra_opt_package_ensure  = 'present',
  $cassandra_package_ensure      = 'present',
  $cassandra_package_name        = 'dsc21',
  $cluster_name                  = 'Test Cluster',
  $java_package_ensure           = 'present',
  $java_package_name             = undef,
  $listen_address                = 'localhost',
  $manage_dsc_repo               = false,
  $manage_service                = true,
  $seeds                         = '127.0.0.1',
  $service_name                  = 'cassandra',
  ) {

  case $::osfamily {
    'RedHat': {
      if $manage_dsc_repo == true {
        yumrepo { 'datastax':
          ensure   => present,
          descr    => 'DataStax Repo for Apache Cassandra',
          baseurl  => 'http://rpm.datastax.com/community',
          enabled  => 1,
          gpgcheck => 0,
          before   => Package[ $cassandra_package_name ],
        }
      }
    }
    default: {
      fail("OS family ${::osfamily} not supported")
    }
  }

  if $java_package_name != undef {
    package { $java_package_name:
      ensure => $java_package_ensure,
      before => Package[ $cassandra_package_name ],
    }
  }

  package { $cassandra_package_name:
    ensure => $cassandra_package_ensure,
  }

  if $cassandra_opt_package_name != undef {
    package { $cassandra_opt_package_name:
      ensure  => $cassandra_opt_package_ensure,
      require => Package[$cassandra_package_name],
    }
  }

  if $manage_service == true {
    file { '/etc/cassandra/default.conf/cassandra.yaml':
      ensure  => file,
      owner   => 'cassandra',
      group   => 'cassandra',
      content => template('cassandra/cassandra.yaml.erb'),
      require => Package[$cassandra_package_name],
      notify  => Service['cassandra'],
    }

    service { 'cassandra':
      name    => $service_name,
      ensure  => running,
      enable  => true,
      require => Package[$cassandra_package_name],
    }
  } else {
    file { '/etc/cassandra/default.conf/cassandra.yaml':
      ensure  => file,
      owner   => 'cassandra',
      group   => 'cassandra',
      content => template('cassandra/cassandra.yaml.erb'),
      require => Package[$cassandra_package_name],
    }
  }
}
