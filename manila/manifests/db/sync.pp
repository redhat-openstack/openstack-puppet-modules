#
class manila::db::sync {

  include manila::params

  exec { 'manila-manage db_sync':
    command     => $::manila::params::db_sync_command,
    path        => '/usr/bin',
    user        => 'manila',
    refreshonly => true,
    require     => [File[$::manila::params::manila_conf], Class['manila']],
    logoutput   => 'on_failure',
  }
}
