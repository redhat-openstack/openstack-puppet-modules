#
# Class to execute "gnocchi-dbsync"
#
# [*user*]
#   (optional) User to run dbsync command.
#   Defaults to 'gnocchi'
#
class gnocchi::db::sync (
  $user = 'gnocchi',
){

  exec { 'gnocchi-db-sync':
    command     => 'gnocchi-upgrade --config-file /etc/gnocchi/gnocchi.conf',
    path        => '/usr/bin',
    refreshonly => true,
    user        => $user,
    logoutput   => on_failure,
  }

  Package<| tag == 'gnocchi-package' |> ~> Exec['gnocchi-db-sync']
  Exec['gnocchi-db-sync'] ~> Service<| tag == 'gnocchi-db-sync-service' |>
  Gnocchi_config<||> ~> Exec['gnocchi-db-sync']
  Gnocchi_config<| title == 'indexer/url' |> ~> Exec['gnocchi-db-sync']
}
