class fluentd::install_repo inherits fluentd {
  case $::osfamily {
    'redhat': {
      yumrepo { $fluentd::repo_name:
        descr    => $fluentd::repo_desc,
        baseurl  => $fluentd::repo_url,
        enabled  => $fluentd::repo_enabled,
        gpgcheck => $fluentd::repo_gpgcheck,
        gpgkey   => $fluentd::repo_gpgkey,
        notify   => Exec['rpmkey'],
      }

      exec { 'rpmkey':
        command     => "rpm --import ${fluentd::repo_gpgkey}",
        path        => '/bin:/usr/bin',
        refreshonly => true,
      }

      # TODO: Remove this dependency. Gem provider requires this package.
      package { 'rubygems':
        ensure => present,
      }
    }

    'debian': {
      apt::source { $fluentd::repo_name:
        location     => $fluentd::repo_url,
        comment      => $fluentd::repo_desc,
        repos        => 'contrib',
        architecture => 'amd64',
        release      => $fluentd::distro_codename,
        key          => {
          id     => $fluentd::repo_gpgkeyid,
          source => $fluentd::repo_gpgkey,
        },
        include      => {
          'src' => false,
          'deb' => true,
        },
      }
    }

    default: {
      fail("Unsupported osfamily ${::osfamily}")
    }
  }
}
