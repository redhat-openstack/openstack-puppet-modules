# == Class kafka::install
#
class kafka::install {

  $basefilename = "kafka_${kafka::scala_version}-${kafka::version}.tgz"
  $basename = regsubst($basefilename, '(.+)\.tgz$', '\1')
  $package_url = "${kafka::mirror_url}/kafka/${kafka::version}/${basefilename}"
  $install_dir = "/usr/local/kafka-${kafka::version}-${kafka::scala_version}"

  group { 'kafka':
    ensure => present
  }

  user { 'kafka':
    ensure  => present,
    shell   => '/bin/bash',
    require => Group['kafka']
  }

  file { $kafka::package_dir:
    ensure => 'directory',
    owner  => 'kafka',
    group  => 'kafka'
  }

  file { "${install_dir}/${kafka::basename}":
    ensure  => directory,
    owner   => 'kafka',
    group   => 'kafka',
    alias   => 'kafka-app-dir'
  }

  ensure_resource('package','wget', {'ensure' => 'installed'})

  exec { 'download-kafka-package':
    command => "wget -O ${kafka::package_dir}/${basefilename} ${package_url} 2> /dev/null",
    path    => ['/usr/bin', '/bin'],
    creates => "${kafka::package_dir}/${basefilename}",
    require => [ File[$kafka::package_dir], Package['wget'] ]
  }

  exec { "untar ${basefilename}":
    command => "tar xfvz ${kafka::package_dir}/${basefilename} -C ${install_dir} --strip-components=1",
    creates => "${install_dir}/${basename}/config",
    alias   => 'untar-kafka',
    require => [ Exec['download-kafka-package'], File['kafka-app-dir'] ],
    user    => 'kafka',
    path    => ['/bin', '/usr/bin', '/usr/sbin']
  }

  file { '/usr/local/kafka':
    ensure => link,
    target => $install_dir
  }
}
