# == Class: ceilometer::db::mysql
#
# The ceilometer::db::mysql class creates a MySQL database for ceilometer.
# It must be used on the MySQL server
#
# === Parameters:
#
# [*password*]
#   (Required) password to connect to the database.
#
# [*dbname*]
#   (Optional) name of the database.
#   Defaults to ceilometer.
#
# [*user*]
#   (Optional) user to connect to the database.
#   Defaults to ceilometer.
#
# [*host*]
#   (Optional) the default source host user is allowed to connect from.
#   Defaults to '127.0.0.1'.
#
# [*allowed_hosts*]
#   (Optional) other hosts the user is allowd to connect from.
#   Defaults to undef.
#
# [*charset*]
#   (Optional) the database charset.
#   Defaults to 'utf8'.
#
# [*collate*]
#   (Optional) the database collation.
#   Defaults to 'utf8_general_ci'.
#
class ceilometer::db::mysql(
  $password      = false,
  $dbname        = 'ceilometer',
  $user          = 'ceilometer',
  $host          = '127.0.0.1',
  $allowed_hosts = undef,
  $charset       = 'utf8',
  $collate       = 'utf8_general_ci',
) {

  validate_string($password)

  ::openstacklib::db::mysql { 'ceilometer':
    user          => $user,
    password_hash => mysql_password($password),
    dbname        => $dbname,
    host          => $host,
    charset       => $charset,
    collate       => $collate,
    allowed_hosts => $allowed_hosts,
  }

  ::Openstacklib::Db::Mysql['ceilometer'] ~> Exec<| title == 'ceilometer-dbsync' |>
}
