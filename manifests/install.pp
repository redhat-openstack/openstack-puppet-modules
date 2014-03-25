# = Private class: kibana3::install
#
# Author: Alejandro Figueroa
class kibana3::install {
  if $::kibana3::manage_git {
    require 'git'
  }

  if $::kibana3::manage_ws {
    class {
      'apache':
      default_vhost => false,
    }
  }

  if $::kibana3::k3_folder_owner {
    $_ws_user = $::kibana3::k3_folder_owner
  } elsif $::kibana3::manage_ws {
    $_ws_user = $::apache::params::user
  } else {
    $_ws_user = 'root'
  }

  if $::kibana3::manage_ws {
    vcsrepo {
      $::kibana3::k3_install_folder:
      ensure   => present,
      provider => git,
      source   => 'https://github.com/elasticsearch/kibana.git',
      revision => $::kibana3::k3_release,
      owner    => $_ws_user,
      notify   => Class['::Apache::Service'],
    }
    ->
    apache::vhost {
      'kibana3':
      port          => $::kibana3::ws_port,
      docroot       => "${::kibana3::k3_install_folder}/src",
      docroot_owner => $_ws_user,
    }
  } else {
    vcsrepo {
      $::kibana3::k3_install_folder:
      ensure   => present,
      provider => git,
      source   => 'https://github.com/elasticsearch/kibana.git',
      revision => $::kibana3::k3_release,
      owner    => $_ws_user,
    }
  }
}
