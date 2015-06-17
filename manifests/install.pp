# == Class: cassandra::install
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra::install (
  $cassandra_opt_package_name   = undef,
  $cassandra_opt_package_ensure = 'present',
  $cassandra_package_ensure     = 'present',
  $cassandra_package_name       = 'dsc21',
  $java_package_ensure          = 'present',
  $java_package_name            = undef,
  $manage_dsc_repo              = false,
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
    'Debian': {
      if $manage_dsc_repo == true {
        include apt
        include apt::update

        apt::key {'datastaxkey':
          key        => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
          key_source => 'http://debian.datastax.com/debian/repo_key',
          before     => Apt::Source['datastax']
        }

        apt::source {'datastax':
          location    => 'http://debian.datastax.com/community',
          comment     => 'DataStax Repo for Apache Cassandra',
          release     => 'stable',
          include_src => false,
          before      => Exec['update-cassandra-repos'],
        }

        # Required to wrap apt_update
        exec {'update-cassandra-repos':
          command => '/bin/true',
          require => Exec['apt_update']
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
}
