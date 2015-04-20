# == define: manila::network::standalone
#
# Setup and configure Manila standalone network communication
#
# === Parameters
#
# [*standalone_network_plugin_gateway*]
# (required) Gateway IPv4 address that should be used. Required
#
# [*standalone_network_plugin_mask*]
# (required) Network mask that will be used. Can be either decimal
# like '24' or binary like '255.255.255.0'. Required.
#
# [*standalone_network_plugin_segmentation_id*]
# (optional) Set it if network has segmentation (VLAN, VXLAN, etc...).
# It will be assigned to share-network and share drivers will be
# able to use this for network interfaces within provisioned
# share servers. Optional. Example: 1001
#
# [*standalone_network_plugin_allowed_ip_ranges*]
# (optional) Can be IP address, range of IP addresses or list of addresses
# or ranges. Contains addresses from IP network that are allowed
# to be used. If empty, then will be assumed that all host
# addresses from network can be used. Optional.
# Examples: 10.0.0.10 or 10.0.0.10-10.0.0.20 or
# 10.0.0.10-10.0.0.20,10.0.0.30-10.0.0.40,10.0.0.50
#
# [*standalone_network_plugin_ip_version*]
# (optional) IP version of network. Optional.
# Allowed values are '4' and '6'. Default value is '4'.
#

define manila::network::standalone (
  $standalone_network_plugin_gateway,
  $standalone_network_plugin_mask,
  $standalone_network_plugin_segmentation_id    = undef,
  $standalone_network_plugin_allowed_ip_ranges  = undef,
  $standalone_network_plugin_ip_version         = '4',
) {

  $standalone_plugin_name = 'manila.network.standalone_network_plugin.StandaloneNetworkPlugin'

  manila_config {
    "${name}/network_api_class":                            value => $standalone_plugin_name;
    "${name}/standalone_network_plugin_gateway":            value => $standalone_network_plugin_gateway;
    "${name}/standalone_network_plugin_mask":               value => $standalone_network_plugin_mask;
    "${name}/standalone_network_plugin_segmentation_id":    value => $standalone_network_plugin_segmentation_id;
    "${name}/standalone_network_plugin_allowed_ip_ranges":  value => $standalone_network_plugin_allowed_ip_ranges;
    "${name}/standalone_network_plugin_ip_version":         value => $standalone_network_plugin_ip_version;
  }
}
