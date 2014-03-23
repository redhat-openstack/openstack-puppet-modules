# = Private class: kibana3::uninstall
#
# Author: Alejandro Figueroa
class kibana3::uninstall {
  if $::kibana3::manage_git {
    package {
      'git':
      ensure => absent,
    }
  }

  if $::kibana3::manage_ws {
    class {
      'apache':
      package_ensure => absent,
    }

    apache::vhost {
      'kibana3':
      ensure => absent,
    }
  }

  file {
    $::kibana3::k3_install_folder:
    ensure => absent,
  }

  file {
    "${::kibana3::k3_install_folder}/src/config.js":
    ensure => absent,
  }
}
