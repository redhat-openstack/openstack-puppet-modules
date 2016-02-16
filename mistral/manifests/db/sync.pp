#
# Class to execute "mistral-db-manage 'upgrade head' and 'populate'"
#
class mistral::db::sync {

  include ::mistral::params

  Package<| tag =='mistral-common'  |> ~> Exec['mistral-db-sync']
  Exec['mistral-db-sync'] ~> Service<| tag == 'mistral-service' |>
  Mistral_config <||> -> Exec['mistral-db-sync']
  Mistral_config <| title == 'database/connection' |> ~> Exec['mistral-db-sync']

  exec { 'mistral-db-sync':
    command     => $::mistral::params::db_sync_command,
    path        => '/usr/bin',
    user        => 'mistral',
    logoutput   => on_failure,
    refreshonly => true,
  }

  Exec['mistral-db-sync'] -> Exec['mistral-db-populate']
  Package<| tag =='mistral-common'  |> ~> Exec['mistral-db-populate']
  Exec['mistral-db-populate'] ~> Service<| tag == 'mistral-service' |>
  Mistral_config <||> -> Exec['mistral-db-populate']
  Mistral_config <| title == 'database/connection' |> ~> Exec['mistral-db-populate']
  exec { 'mistral-db-populate':
    command     => $::mistral::params::db_populate_command,
    path        => '/usr/bin',
    user        => 'mistral',
    logoutput   => on_failure,
    refreshonly => true,
  }

}
