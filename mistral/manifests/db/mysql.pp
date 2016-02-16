# The mistral::db::mysql class implements mysql backend for mistral
#
# This class can be used to create tables, users and grant
# privilege for a mysql mistral database.
#
# == parameters
#
# [*password*]
#   (Mandatory) Password to connect to the database.
#   Defaults to 'false'.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'mistral'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'mistral'.
#
# [*host*]
#   (Optional) The default source host user is allowed to connect from.
#   Defaults to '127.0.0.1'
#
# [*allowed_hosts*]
#   (Optional) Other hosts the user is allowed to connect from.
#   Defaults to 'undef'.
#
# [*charset*]
#   (Optional) The database charset.
#   Defaults to 'utf8'
#
# [*collate*]
#   (Optional) The database collate.
#   Only used with mysql modules >= 2.2.
#   Defaults to 'utf8_general_ci'
#
# [*listening_service*]
#    The name that will be called from the mysql machine
#    Defaults to 'mistral_db'.
#
# == Dependencies
#   Class['mysql::server']
#
# == Examples
#
# == Authors
#
# == Copyright
#
class mistral::db::mysql(
  $password,
  $listening_service = 'mistral_db',
  $dbname        = 'mistral',
  $user          = 'mistral',
  $host          = '127.0.0.1',
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
  $allowed_hosts = undef
) {

  validate_string($password)

  ::openstacklib::db::mysql { 'mistral':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

}
