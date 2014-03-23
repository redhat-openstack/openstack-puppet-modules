# = Private class: kibana3::config
#
# Author: Alejandro Figueroa
class kibana3::config {
  if $::kibana3::manage_ws {
    file {
      "${::kibana3::k3_install_folder}/src/config.js":
      ensure  => present,
      content => template('kibana3/config.js.erb'),
      owner   => $::kibana3::install::_ws_user,
      notify  => Class['::Apache::Service'],
    }
  } else {
    file {
      "${::kibana3::k3_install_folder}/src/config.js":
      ensure  => present,
      content => template('kibana3/config.js.erb'),
      owner   => $::kibana3::install::_ws_user,
    }
  }
}
