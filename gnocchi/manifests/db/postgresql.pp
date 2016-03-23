# == Class: gnocchi::db::postgresql
#
# Class that configures postgresql for gnocchi
# Requires the Puppetlabs postgresql module.
#
# === Parameters
#
# [*password*]
#   (Required) Password to connect to the database.
#
# [*dbname*]
#   (Optional) Name of the database.
#   Defaults to 'gnocchi'.
#
# [*user*]
#   (Optional) User to connect to the database.
#   Defaults to 'gnocchi'.
#
#  [*encoding*]
#    (Optional) The charset to use for the database.
#    Default to undef.
#
#  [*privileges*]
#    (Optional) Privileges given to the database user.
#    Default to 'ALL'
#
class gnocchi::db::postgresql(
  $password,
  $dbname     = 'gnocchi',
  $user       = 'gnocchi',
  $encoding   = undef,
  $privileges = 'ALL',
) {

  Class['gnocchi::db::postgresql'] -> Service<| title == 'gnocchi' |>

  ::openstacklib::db::postgresql { 'gnocchi':
    password_hash => postgresql_password($user, $password),
    dbname        => $dbname,
    user          => $user,
    encoding      => $encoding,
    privileges    => $privileges,
  }

  ::Openstacklib::Db::Postgresql['gnocchi']    ~> Exec<| title == 'gnocchi-db-sync' |>
}
