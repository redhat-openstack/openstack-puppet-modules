# == define: manila::network::nova_network
#
# Setup and configure Nova Networking communication
#

define manila::network::nova_network () {
  $nova_net_plugin_name = 'manila.network.nova_network_plugin.NovaNetworkPlugin'

  manila_config {
    "${name}/network_api_class": value => $nova_net_plugin_name;
  }
}
