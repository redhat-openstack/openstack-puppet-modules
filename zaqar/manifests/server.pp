# = Class: zaqar::server
#
# This class manages the Zaqar server.
#
# [*enabled*]
#   (Optional) Service enable state for zaqar-server.
#   Defaults to true.
#
# [*manage_service*]
#   (Optional) Whether the service is managed by this puppet class.
#   Defaults to true.
#
class zaqar::server(
  $manage_service = true,
  $enabled        = true,
) {

  include ::zaqar
  include ::zaqar::params

  if $manage_service {
    if $enabled {
      $service_ensure = 'running'
    } else {
      $service_ensure = 'stopped'
    }
  }

  if $manage_service {
    service { $::zaqar::params::service_name:
      ensure => $service_ensure,
      enable => $enabled,
    }
    Zaqar_config<||> ~> Service[$::zaqar::params::service_name]
  }

}
