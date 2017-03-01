# == Class zookeeper::install
#
class zookeeper::install inherits zookeeper {

  package { 'zookeeper-server':
    ensure => $package_ensure,
    name   => $package_name,
  }

  # We provide a custom zookeeper-server startup script.  This script fixes a problem where supervisord is not able to
  # restart the ZooKeeper processes (parent and child).  See https://github.com/miguno/puppet-zookeeper/issues/1.
  file { $zookeeper_start_binary:
    ensure  => file,
    source  => "puppet:///modules/${module_name}/zookeeper-server",
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['zookeeper-server'],
  }

  # This exec ensures we create intermediate directories for $data_dir as required
  exec { 'create-zookeeper-data-directory':
    command => "mkdir -p ${data_dir}",
    path    => ['/bin', '/sbin', '/usr/bin/', '/usr/sbin/'],
    unless  => "test -d ${data_dir}",
    require => Package['zookeeper-server'],
  }
  ->
  file { $data_dir:
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0755',
    recurse      => true,
    recurselimit => 0,
    # Require is needed because the zookeeper-server package manages the user
    require      => Package['zookeeper-server'],
  }
  ->
  file { "${data_dir}/version-2":
    ensure       => directory,
    owner        => $user,
    group        => $group,
    mode         => '0755',
    recurse      => true,
    recurselimit => 0,
    # Require is needed because the zookeeper-server package manages the user
    require      => Package['zookeeper-server'],
  }

  if $data_log_dir != $data_dir {
    # This exec ensures we create intermediate directories for $data_dir as required
    exec { 'create-zookeeper-data-log-directory':
      command => "mkdir -p ${data_log_dir}",
      path    => ['/bin', '/sbin', '/usr/bin/', '/usr/sbin/'],
      unless  => "test -d ${data_log_dir}",
      require => Package['zookeeper-server'],
    }
    ->
    file { $data_log_dir:
      ensure       => directory,
      owner        => $user,
      group        => $group,
      mode         => '0755',
      recurse      => true,
      recurselimit => 0,
      # Require is needed because the zookeeper-server package manages the user
      require      => Package['zookeeper-server'],
    }
    ->
    file { "${data_log_dir}/version-2":
      ensure       => directory,
      owner        => $user,
      group        => $group,
      mode         => '0755',
      recurse      => true,
      recurselimit => 0,
      # Require is needed because the zookeeper-server package manages the user
      require      => Package['zookeeper-server'],
    }
  }

}
