# Class: zookeeper
#
# This module manages zookeeper
#
# Parameters:
#   user
#   group
#   log_dir
#
# Requires:
#   N/A
# Sample Usage:
#   
#   class { 'zookeeper': }
#
class zookeeper {
  require zookeeper::install
  include zookeeper::params
  
  file { "${log_dir}":
    owner => $user,
    group => $group,
    mode => 644,
    ensure => directory,
  }

  file { "${datastore}":
    ensure => directory, 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
  }

  file { "${cfg_dir}/myid":
    ensure => file, 
    content => template("zookeeper/conf/myid.erb"), 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
    require => File["${datastore}"],
  }

  file { "${cfg_dir}/zoo.cfg":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/zoo.cfg.erb"), 
  }

  file { "${cfg_dir}/environment":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/environment.erb"), 
  }

  file { "${cfg_dir}/log4j.properties":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/log4j.properties.erb"), 
  }

  service { "zookeeper":
    ensure  => "running",
    enable  => "true",
  }

}
