#
# Class to execute "keystone-manage db_sync
#
# == Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the keystone-manage db_sync command.  These will be
#   inserted in the command line between 'keystone-manage' and
#   'db_sync' in the command line.
#   Defaults to ''
#
class keystone::db::sync(
  $extra_params  = undef,
) {
  exec { 'keystone-manage db_sync':
    command     => "keystone-manage ${extra_params} db_sync",
    path        => '/usr/bin',
    user        => 'keystone',
    refreshonly => true,
    subscribe   => [Package['keystone'], Keystone_config['database/connection']],
    require     => User['keystone'],
  }

  Exec['keystone-manage db_sync'] ~> Service<| title == 'keystone' |>
}
