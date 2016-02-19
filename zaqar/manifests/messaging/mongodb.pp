# == class: zaqar::messaging::mongodb
#
# [*uri*]
#   Mongodb Connection URI. Required.
#
# [*ssl_keyfile*]
#   The private keyfile used to identify the local connection against
#   mongod. Default $::os_service_default
#   Defaults to $::os_service_default.
#
# [*ssl_certfile*]
#   The certificate file used to identify the local connection against
#   mongod. (string value)
#   Defaults to $::os_service_default.
#
# [*ssl_cert_reqs*]
#   Specifies whether a certificate is required from the other side of
#   the connection, and whether it will be validated if provided. It
#   must be one of the three values ``CERT_NONE``(certificates ignored),
#   ``CERT_OPTIONAL``(not required, but validated if provided), or
#   ``CERT_REQUIRED``(required and validated).
#   Defaults to $::os_service_default.
#
# [*ssl_ca_certs*]
#   The ca_certs file contains a set of concatenated "certification
#   authority" certificates, which are used to validate certificates
#   passed from the other end of the connection.
#   Defaults to $::os_service_default.
#
# [*database*]
#   Database name. (string value). Defaults to $::os_service_default.
#
# [*max_attempts*]
#   Maximum number of times to retry a failed operation. Currently only
#   used for retrying a message post.
#   Defaults to $::os_service_default.
#
# [*max_retry_sleep*]
#   Maximum sleep interval between retries (actual sleep time increases
#   linearly according to number of attempts performed).
#   Defaults to $::os_service_default.
#
# [*max_retry_jitter*]
#   Maximum jitter interval, to be added to the sleep interval, in order
#   to decrease probability that parallel requests will retry at the
#   same instant. (floating point value)
#   Defaults to $::os_service_default.
#
# [*max_reconnect_attempts*]
#   Maximum number of times to retry an operation that failed due to a
#   primary node failover. (integer value)
#   Defaults to $::os_service_default.
#
# [*reconnect_sleep*]
#   Base sleep interval between attempts to reconnect after a primary
#   node failover. The actual sleep time increases exponentially (power
#   of 2) each time the operation is retried. (floating point value)
#   Defaults to $::os_service_default.
#
# [*partitions*]
#   Number of databases across which to partition message data, in order
#   to reduce writer lock %. DO NOT change this setting after initial
#   deployment. It MUST remain static.
#   Defaults to $::os_service_default.
class zaqar::messaging::mongodb(
  $uri,
  $ssl_keyfile            = $::os_service_default,
  $ssl_certfile           = $::os_service_default,
  $ssl_cert_reqs          = $::os_service_default,
  $ssl_ca_certs           = $::os_service_default,
  $database               = $::os_service_default,
  $max_attempts           = $::os_service_default,
  $max_retry_sleep        = $::os_service_default,
  $max_retry_jitter       = $::os_service_default,
  $max_reconnect_attempts = $::os_service_default,
  $reconnect_sleep        = $::os_service_default,
  $partitions             = $::os_service_default,
) {

  zaqar_config {
    'drivers/message_store': value => 'mongodb';
    'drivers:message_store:mongodb/uri': value => $uri, secret => true;
    'drivers:message_store:mongodb/ssl_keyfile': value => $ssl_keyfile;
    'drivers:message_store:mongodb/ssl_certfile': value => $ssl_certfile;
    'drivers:message_store:mongodb/ssl_cert_reqs': value => $ssl_cert_reqs;
    'drivers:message_store:mongodb/ssl_ca_certs': value => $ssl_ca_certs;
    'drivers:message_store:mongodb/database': value => $database;
    'drivers:message_store:mongodb/max_attempts': value => $max_attempts;
    'drivers:message_store:mongodb/max_retry_sleep': value => $max_retry_sleep;
    'drivers:message_store:mongodb/max_retry_jitter': value => $max_retry_jitter;
    'drivers:message_store:mongodb/max_reconnect_attempts': value => $max_reconnect_attempts;
    'drivers:message_store:mongodb/reconnect_sleep': value => $reconnect_sleep;
    'drivers:message_store:mongodb/partitions': value => $partitions;
  }

}
