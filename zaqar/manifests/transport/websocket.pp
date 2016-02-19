# == class: zaqar::transport::websocket
#
# [*bind*]
#   Address on which the self-hosting server will listen.
#   Defaults to $::os_service_default.
#
# [*port*]
#   Port on which the self-hosting server will listen.
#   Defaults to $::os_service_default.
#
# [*external_port*]
#   Port on which the service is provided to the user.
#   Defaults to $::os_service_default.
#
class zaqar::transport::websocket(
  $bind           = $::os_service_default,
  $port           = $::os_service_default,
  $external_port  = $::os_service_default,
) {

  zaqar_config {
    'drivers:transport:websocket/bind': value => $bind;
    'drivers:transport:websocket/port': value => $port;
    'drivers:transport:websocket/external-port': value => $external_port;
  }

}
