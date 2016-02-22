# == class: zaqar::transport::wsgi
#
# [*bind*]
#   Address on which the self-hosting server will listen.
#   Defaults to $::os_service_default.
#
# [*port*]
#   Port on which the self-hosting server will listen.
#   Defaults to $::os_service_default.
#
class zaqar::transport::wsgi(
  $bind = $::os_service_default,
  $port = $::os_service_default,
) {

  zaqar_config {
    'drivers:transport:wsgi/bind': value => $bind;
    'drivers:transport:wsgi/port': value => $port;
  }

}
