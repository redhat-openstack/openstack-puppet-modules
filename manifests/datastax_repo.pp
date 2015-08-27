# == Class: cassandra::datastax_repo
#
# Please see the README for this module for full details of what this class
# does as part of the module and how to use it.
#
class cassandra::datastax_repo {
  case $::osfamily {
    'RedHat': {
      yumrepo { 'datastax':
        ensure   => present,
        descr    => 'DataStax Repo for Apache Cassandra',
        baseurl  => 'http://rpm.datastax.com/community',
        enabled  => 1,
        gpgcheck => 0,
      }
    }
    'Debian': {
      include apt
      include apt::update

      apt::key {'datastaxkey':
        key     => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        key_source => 'http://debian.datastax.com/debian/repo_key',
        before => Apt::Source['datastax']
      }

      apt::source {'datastax':
        location => 'http://debian.datastax.com/community',
        comment  => 'DataStax Repo for Apache Cassandra',
        release  => 'stable',
        include_src  => false,
        notify   => Exec['update-cassandra-repos']
      }

      # Required to wrap apt_update
      exec {'update-cassandra-repos':
        refreshonly => true,
        command     => '/bin/true',
        require     => Exec['apt_update'],
      }
    }
    default: {
      warning("OS family ${::osfamily} not supported")
    }
  }
}
