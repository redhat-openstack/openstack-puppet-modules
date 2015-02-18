# == Class: manila::db::postgresql
#
# Class that configures postgresql for manila
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'manila'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'manila'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
class manila::db::postgresql(
  $password,
  $dbname     = 'manila',
  $user       = 'manila',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  ::openstacklib::db::postgresql { 'manila':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  ::Openstacklib::Db::Postgresql['manila']    ~> Exec<| title == 'manila-manage db_sync' |>

}
