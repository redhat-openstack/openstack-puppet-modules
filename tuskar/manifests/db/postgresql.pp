# == Class: tuskar::db::postgresql
#
# Class that configures postgresql for tuskar
# Requires the Puppetlabs postgresql module.
#
# === Parameters:
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'tuskar'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'tuskar'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
class tuskar::db::postgresql(
  $password,
  $dbname     = 'tuskar',
  $user       = 'tuskar',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  Class['tuskar::db::postgresql'] -> Service<| title == 'tuskar' |>

  ::openstacklib::db::postgresql { 'tuskar':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  ::Openstacklib::Db::Postgresql['tuskar'] ~> Exec<| title == 'tuskar-dbsync' |>

}
