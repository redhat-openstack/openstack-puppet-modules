# Class: zookeeper::config
#
# This module manages the zookeeper configuration directories
#
# Parameters:
# [* id *]  zookeeper instance id: between 1 and 255
#
# Actions: None
#
# Requires: zookeeper::install, zookeeper
#
# Sample Usage: include zookeeper::config
#
class zookeeper::config(
  $id      = 1
  $user    = 'zookeeper',
  $group   = 'zookeeper',
  $log_dir = '/var/log/zookeeper',
  $cfg_dir = '/etc/zookeeper/conf',
  $datastore   = '/var/lib/zookeeper',
) {
  require zookeeper::install

  file { $cfg_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0644',
  }

  file { $log_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => '0644',
  }

  file { $datastore:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    recurse => true,
  }

  file { "${cfg_dir}/myid":
    ensure  => file,
    content => template('zookeeper/conf/myid.erb'),
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => File[$cfg_dir]
  }

  file { "${cfg_dir}/zoo.cfg":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/zoo.cfg.erb'),
  }

  file { "${cfg_dir}/environment":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/environment.erb'),
  }

  file { "${cfg_dir}/log4j.properties":
    owner   => $user,
    group   => $group,
    mode    => '0644',
    content => template('zookeeper/conf/log4j.properties.erb'),
  }

}
