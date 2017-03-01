# == define: manila::network::nova_single_network
#
# Setup and configure Nova Networking communication with a single network
#
# === Parameters
#
# [*nova_single_network_plugin_net_id*]
# (required) Default Nova network that will be used for share servers.
# This opt is used only with class 'NovaSingleNetworkPlugin'.
#

define manila::network::nova_single_network (
  $nova_single_network_plugin_net_id,
) {

  $nova_single_net_plugin_name = 'manila.network.nova_network_plugin.NovaSingleNetworkPlugin'

  manila_config {
    "${name}/network_api_class":                 value => $nova_single_net_plugin_name;
    "${name}/nova_single_network_plugin_net_id": value => $nova_single_network_plugin_net_id;
  }
}
