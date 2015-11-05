# == Class: contrail::webui::service
#
# Manage the webui service
#
class contrail::webui::service {

  service {'supervisor-webui' :
    ensure => running,
    enable => true,
  }

}
