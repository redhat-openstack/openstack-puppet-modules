#
# Class to execute "zaqar-manage db_sync
#
class zaqar::db::sync {
  exec { 'zaqar-manage db_sync':
    path        => '/usr/bin',
    user        => 'zaqar',
    refreshonly => true,
    subscribe   => [Package['zaqar'], Zaqar_config['database/connection']],
    require     => User['zaqar'],
  }

  Exec['zaqar-manage db_sync'] ~> Service<| title == 'zaqar' |>
}
