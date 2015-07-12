#
# Class to execute neutron dbsync
#
class neutron::db::sync (
  $service_plugins = $::neutron::service_plugins
) {

  include ::neutron::params

  Package<| title == 'neutron-server' |> -> Exec['neutron-db-sync']
  Package<| title == 'neutron' |> -> Exec['neutron-db-sync']
  Neutron_config<||> ~> Exec['neutron-db-sync']
  Neutron_config<| title == 'database/connection' |> ~> Exec['neutron-db-sync']
  Exec['neutron-db-sync'] ~> Service <| title == 'neutron-server' |>

  exec { 'neutron-db-sync':
    command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
    path        => '/usr/bin',
    refreshonly => true,
    logoutput   => on_failure,
  }

  if ($service_plugins and ('lbaas' in $service_plugins or
      'neutron.services.loadbalancer.plugin.LoadBalancerPlugin' in $service_plugins)) {
    Exec['neutron-db-sync'] ~> Exec['neutron-db-sync-lbaas']
    Exec['neutron-db-sync-lbaas'] ~> Service <| title == 'neutron-server' |>
    exec { 'neutron-db-sync-lbaas':
      command     => 'neutron-db-manage  --service lbaas --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
      path        => '/usr/bin',
      refreshonly => true,
      logoutput   => on_failure,
    }
  }

  if ($service_plugins and ('firewall' in $service_plugins or
      'neutron.services.firewall.fwaas_plugin.FirewallPlugin' in $service_plugins)) {
    Exec['neutron-db-sync'] ~> Exec['neutron-db-sync-fwaas']
    Exec['neutron-db-sync-fwaas'] ~> Service <| title == 'neutron-server' |>
    exec { 'neutron-db-sync-fwaas':
      command     => 'neutron-db-manage  --service fwaas --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
      path        => '/usr/bin',
      refreshonly => true,
      logoutput   => on_failure,
    }
  }

  if ($service_plugins and ('vpnaas' in $service_plugins or
      'neutron_vpnaas.services.vpn.plugin:VPNDriverPlugin' in $service_plugins)) {
    Exec['neutron-db-sync'] ~> Exec['neutron-db-sync-vpnaas']
    Exec['neutron-db-sync-vpnaas'] ~> Service <| title == 'neutron-server' |>
    exec { 'neutron-db-sync-vpnaas':
      command     => 'neutron-db-manage  --service vpnaas --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
      path        => '/usr/bin',
      refreshonly => true,
      logoutput   => on_failure,
    }
  }
}
