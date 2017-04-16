#
# Class that configures postgresql for manila
#
# Requires the Puppetlabs postgresql module.
class manila::db::postgresql(
  $password,
  $dbname = 'manila',
  $user   = 'manila'
) {

  require postgresql::python

  Postgresql::Db[$dbname]    ~> Exec<| title == 'manila-manage db_sync' |>
  Package['python-psycopg2'] -> Exec<| title == 'manila-manage db_sync' |>

  postgresql::db { $dbname:
    user      =>  $user,
    password  =>  $password,
  }

}
