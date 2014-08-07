# == Class uchiwa::install
#
class uchiwa::install {
  case $::osfamily {
    'Debian': {
      class { 'uchiwa::repo::apt': }
    }

    'RedHat': {
      class { 'uchiwa::repo::yum': }
    }

    default: { alert("${::osfamily} not supported yet") }
  }

  if $uchiwa::manage_user {
    user { 'uchiwa':
      ensure  => 'present',
      system  => true,
      home    => '/opt/uchiwa',
      shell   => '/bin/false',
      comment => 'Uchiwa Monitoring Dashboard',
    }

    group { 'uchiwa':
      ensure  => 'present',
      system  => true,
    }
  }

  package { $uchiwa::package_name:
    ensure => $uchiwa::version,
  }

}
