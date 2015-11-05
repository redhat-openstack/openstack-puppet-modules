# == Class zookeeper::config
#
class zookeeper::config inherits zookeeper {

  file { $config:
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template($config_template),
    require => Class['zookeeper::install'],
  }

  if $is_standalone == false {
    file { 'zookeeper-myid':
      ensure  => file,
      path    => "${data_dir}/myid",
      owner   => $user,
      group   => $group,
      mode    => '0644',
      content => "${myid}\n",
      require => Class['zookeeper::install'],
    }
  }

}
