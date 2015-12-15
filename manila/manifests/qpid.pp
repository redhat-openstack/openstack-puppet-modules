# == Class: manila::qpid
#
# Deprecated class for installing qpid server for manila
#
# === Parameters
#
# [*enabled*]
#   (Optional) Whether to enable the service
#   Defaults to undef.
#
# [*user*]
#   (Optional) The user to create in qpid
#   Defaults to undef.
#
# [*password*]
#   (Optional) The password to create for the user
#   Defaults to undef.
#
# [*file*]
#   (Optional) Sasl file for the user
#   Defaults to undef.
#
# [*realm*]
#   (Optional) Realm for the user
#   Defaults to undef.
#
class manila::qpid (
  $enabled  = undef,
  $user     = undef,
  $password = undef,
  $file     = undef,
  $realm    = undef
) {
  warning('Qpid driver is removed from Oslo.messaging in the Mitaka release')
}
