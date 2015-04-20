# == define: manila::network::neutron_single_network
#
# Setup and configure the Neutron single network plugin
#
# === Parameters
#
# [*neutron_net_id*]
# (required) Default Neutron network that will be used for share server
# creation. This opt is used only with
# class 'NeutronSingleNetworkPlugin'.
#
# [*neutron_subnet_id*]
# (required) Default Neutron subnet that will be used for share server
# creation. Should be assigned to network defined in opt
# 'neutron_net_id'. This opt is used only with
# class 'NeutronSingleNetworkPlugin'.
#

define manila::network::neutron_single_network (
  $neutron_net_id,
  $neutron_subnet_id,
) {

  $neutron_single_plugin_name = 'manila.network.neutron.neutron_network_plugin.NeutronSingleNetworkPlugin'

  manila_config {
    "${name}/network_api_class": value => $neutron_single_plugin_name;
    "${name}/neutron_net_id":    value => $neutron_net_id;
    "${name}/neutron_subnet_id": value => $neutron_subnet_id;
  }
}
