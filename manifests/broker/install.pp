# == Class kafka::broker::install
#
# This private class installs a kafka broker package and it's dependencies
#
class kafka::broker::install {

  $basefilename = "kafka_${kafka::broker::scala_version}-${kafka::broker::version}.tgz"
  $basename = regsubst($basefilename, '(.+)\.tgz$', '\1')
  $package_url = "${kafka::broker::mirror_url}/kafka/${kafka::broker::version}/${basefilename}"
  $install_dir = "/usr/local/kafka-${kafka::broker::scala_version}-${kafka::broker::version}"

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $kafka::broker::install_java {
    class {'java':
      distribution => 'jdk'
    }
  }

  group { 'kafka':
    ensure => present
  }

  user { 'kafka':
    ensure  => present,
    shell   => '/bin/bash',
    require => Group['kafka']
  }

  file { $kafka::broker::package_dir:
    ensure => 'directory',
    owner  => 'kafka',
    group  => 'kafka'
  }

  file { $install_dir:
    ensure  => directory,
    owner   => 'kafka',
    group   => 'kafka',
    alias   => 'kafka-app-dir'
  }

  ensure_resource('package','wget', {'ensure' => 'installed'})

  exec { 'download-kafka-package':
    command => "wget -O ${kafka::broker::package_dir}/${basefilename} ${package_url} 2> /dev/null",
    path    => ['/usr/bin', '/bin'],
    creates => "${kafka::broker::package_dir}/${basefilename}",
    require => [ File[$kafka::broker::package_dir], Package['wget'] ]
  }

  exec { 'untar-kafka-package':
    command => "tar xfvz ${kafka::broker::package_dir}/${basefilename} -C ${install_dir} --strip-components=1",
    creates => "${install_dir}/${basename}/config",
    alias   => 'untar-kafka',
    require => [ Exec['download-kafka-package'], File['kafka-app-dir'] ],
    user    => 'kafka',
    path    => ['/bin', '/usr/bin', '/usr/sbin']
  }

  file { '/usr/local/kafka':
    ensure => link,
    owner  => 'kafka',
    group  => 'kafka',
    target => $install_dir
  }
}
