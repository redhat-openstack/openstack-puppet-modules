# == Class: zaqar::db::postgresql
#
# Class that configures postgresql for zaqar
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'zaqar'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'zaqar'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
# == Dependencies
#
# == Examples
#
# == Authors
#
# == Copyright
#
class zaqar::db::postgresql(
  $password,
  $dbname     = 'zaqar',
  $user       = 'zaqar',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  Class['zaqar::db::postgresql'] -> Service<| title == 'zaqar' |>

  ::openstacklib::db::postgresql { 'zaqar':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  ::Openstacklib::Db::Postgresql['zaqar'] ~> Exec<| title == 'zaqar-manage db_sync' |>

}
