# == Class uchiwa::install
#
class uchiwa::install {
  case $::osfamily {
    'Debian': {
      class { 'uchiwa::repo::apt': }
      if ($uchiwa::install_repo) {
        $repo_require = Apt::Source['sensu']
      } else {
        $repo_require = undef
      }
    }

    'RedHat': {
      class { 'uchiwa::repo::yum': }
      if ($uchiwa::install_repo) {
        $repo_require = Yumrepo['sensu']
      } else {
        $repo_require = undef
      }
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
    ensure  => $uchiwa::version,
    require => $repo_require,
  }

}
