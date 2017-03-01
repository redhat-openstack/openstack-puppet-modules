#
# Class to execute "aodh-manage db_sync
#
class aodh::db::sync {
  exec { 'aodh-manage db_sync':
    path        => '/usr/bin',
    user        => 'aodh',
    refreshonly => true,
    subscribe   => [Package['aodh'], Aodh_config['database/connection']],
    require     => User['aodh'],
  }

  Exec['aodh-manage db_sync'] ~> Service<| title == 'aodh' |>
}
