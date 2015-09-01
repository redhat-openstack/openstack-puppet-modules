# === Parameters:
#
# [*network*]
#   (required) IPv4 CIDR of network to create.
#
# [*label*]
#   (optional) The label of the network.
#   Defaults to 'novanetwork'.
#
# [*num_networks*]
#   (optional) Number of networks to split $network into.
#   Defaults to 1
#
# [*network_size*]
#   (optional) Size of the network to create
#   Defaults to 255
#
# [*vlan_start*]
#   (optional) The vlan number to use if in vlan mode
#   Defaults to undef
#
# [*allowed_start*]
#   (optional) Start of allowed addresses for instances
#   Defaults to undef
#
# [*allowed_end*]
#   (optional) End of allowed addresses for instances
#   Defaults to undef
#
# [*project*]
#   (optional) Project that network should be associated with
#   Defaults to undef
#
# [*dns1*]
#   (optional) First DNS server
#   Defaults to undef
#
# [*dns2*]
#   (optional) Second DNS server
#   Defaults to undef
#
define nova::manage::network (
  $network,
  $label         = 'novanetwork',
  $num_networks  = 1,
  $network_size  = 255,
  $vlan_start    = undef,
  $project       = undef,
  $allowed_start = undef,
  $allowed_end   = undef,
  $dns1          = undef,
  $dns2          = undef
) {

  File['/etc/nova/nova.conf'] -> Nova_network[$name]
  Exec<| title == 'nova-db-sync' |> -> Nova_network[$name]

  nova_network { $name:
    ensure        => present,
    network       => $network,
    label         => $label,
    num_networks  => $num_networks,
    network_size  => $network_size,
    project       => $project,
    vlan_start    => $vlan_start,
    allowed_start => $allowed_start,
    allowed_end   => $allowed_end,
    dns1          => $dns1,
    dns2          => $dns2,
  }

}
