# Class: zookeeper::config
#
# This module manages the zookeeper configuration directories
#
# Parameters: None
#
# Actions: None
#
# Requires: zookeeper::install, zookeeper
#
# Sample Usage: include zookeeper::config
#
class zookeeper::config(
  $user    = 'zookeeper',
  $group   = 'zookeeper',
  $log_dir = '/var/log/zookeeper',
  $cfg_dir = '/etc/zookeeper/conf',
  $datastore   = '/var/lib/zookeeper',
) {
  require zookeeper::install

  file { "$cfg_dir":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    recurse => true,
  }

  file { "$log_dir":
    owner   => $user,
    group   => $group,
    recurse => true,
    mode    => 644,
    ensure  => directory,
  }

  file { "$datastore":
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => 644,
    recurse => true,
  }

  file { "${cfg_dir}/myid":
    ensure  => file,
    content => template("zookeeper/conf/myid.erb"),
    owner   => $user,
    group   => $group,
    mode    => 644,
    require => File["${cfg_dir}"]
  }

  file { "${cfg_dir}/zoo.cfg":
    owner   => $user,
    group   => $group,
    mode    => 644,
    content => template("zookeeper/conf/zoo.cfg.erb"),
  }

  file { "${cfg_dir}/environment":
    owner   => $user,
    group   => $group,
    mode    => 644,
    content => template("zookeeper/conf/environment.erb"),
  }

  file { "${cfg_dir}/log4j.properties":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/log4j.properties.erb"),
  }

}
