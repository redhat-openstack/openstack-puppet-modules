#
# Class to execute "aodh-dbsync"
#
# [*user*]
#   (optional) User to run dbsync command.
#   Defaults to 'aodh'
#
class aodh::db::sync (
  $user = 'aodh',
){
  exec { 'aodh-db-sync':
    command     => 'aodh-dbsync --config-file /etc/aodh/aodh.conf',
    path        => '/usr/bin',
    refreshonly => true,
    user        => $user,
    logoutput   => on_failure,
  }

  Package<| tag == 'aodh-package' |> ~> Exec['aodh-db-sync']
  Exec['aodh-db-sync'] ~> Service<| tag == 'aodh-db-sync-service' |>
  Aodh_config<||> ~> Exec['aodh-db-sync']
  Aodh_config<| title == 'database/connection' |> ~> Exec['aodh-db-sync']
}
