# Class: zookeeper
#
# This module manages zookeeper
#
# Parameters:
#   tmp_dir
#   user
#   group
#   version
#   zookeeper_path
#   log_dir
#
# Actions:
#   deploy zookeeper
#   deploy zk coniguration
#
# Requires:
#   N/A
# Sample Usage:
#   $myid=1
#   include zookeeper
#
class zookeeper(
  $myid,
  $datastore       = $zookeeper::params::datastore,
  $datastore_log   = $zookeeper::params::datastore_log,
  $tmp_dir         = $zookeeper::params::tmp_dir,
  $tarball         = "zookeeper-${version}.tar.gz",
  $log_dir         = $zookeeper::params::log_dir,
  $init_d_path     = $zookeeper::params::init_d_path,
  $init_d_template = $zookeeper::params::init_d_template,
  $user            = $zookeeper::params::user,
  $version         = $zookeeper::params::version,
  $zookeeper_path  = $zookeeper::params::zookeeper_path,
) inherits zookeeper::params {
  
  #full path to zookeeper folder
  $zookeeper_home = "${zookeeper_path}/zookeeper"

  #check if it's already installed
  Exec {
    unless => "test -f ${zookeeper_path}/zookeeper/bin/zkServer.sh"
  }
  
  # get files
  file {"zookeeper-tarball":
    path => "${tmp_dir}/${tarball}",
    source => "puppet:///modules/zookeeper/${tarball}",
    ensure => file,
  }

  exec { "zookeeper_untar":
    command => "tar -xzf ${tmp_dir}/${tarball}",
    cwd => "${tmp_dir}",
    user => "$user",
    require => File["zookeeper-tarball"],
    creates => "${tmp_dir}/zookeeper-${version}",
  }
  
  exec { "move-zookeeper-directory":
    command => "mv ${tmp_dir}/zookeeper-${version} ${zookeeper_path}/zookeeper",
    creates => "${zookeeper_home}",
    user => "root",
    require => Exec["zookeeper_untar"],
  }
  

  file { "${zookeeper_home}/zookeeper-${version}":
    recurse => true,
    owner => $user,
    group => $group,
    require => Exec["move-zookeeper-directory"],
    backup => false,
  }

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
    require => Exec["move-zookeeper-directory"],
  }

  file { "${datastore}/myid":
    ensure => file, 
    content => template("zookeeper/conf/${environment}/myid.erb"), 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
    require => File["${datastore}"],
  }

  file { "${datastore_log}":
    ensure => directory, 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
    require => Exec["move-zookeeper-directory"],
  }

  file { "${zookeeper_home}/conf/zoo.cfg":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/${environment}/zoo.cfg.erb"), 
    require => Exec["move-zookeeper-directory"],
  }

  file { "${zookeeper_home}/conf/java.env":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/${environment}/java.env.erb"), 
    require => Exec["move-zookeeper-directory"],
  }

  file { "${zookeeper_home}/conf/log4j.properties":
    owner => $user,
    group => $group,
    mode => 644,
    content => template("zookeeper/conf/${environment}/log4j.properties.erb"), 
    require => Exec["move-zookeeper-directory"],
  }

  file { "${init_d_path}":
      content => template("zookeeper/service/zookeeper.erb"),
      ensure => file,
      owner => "root",
      group => "root",
      mode => 755,
    #  create => "/etc/init.d/zookeeper-server",
  }

  service { "zookeeper":
    ensure  => "running",
    enable  => "true",
  }

}
