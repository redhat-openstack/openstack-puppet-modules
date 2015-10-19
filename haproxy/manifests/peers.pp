# == Defined Type: haproxy::peers
#
#  This type will set up a peers entry in haproxy.cfg
#   on the load balancer. This setting is required to share the
#   current state of HAproxy with other HAproxy in High available
#   configurations.
#
# === Parameters
#
# [*name*]
#  Sets the peers' name. Generally it will be the namevar of the
#   defined resource type. This value appears right after the
#   'peers' statement in haproxy.cfg

define haproxy::peers (
  $collect_exported = true,
) {

  # Template uses: $name, $ipaddress, $ports, $options
  concat::fragment { "${name}_peers_block":
    order   => "30-peers-00-${name}",
    target  => $::haproxy::config_file,
    content => template('haproxy/haproxy_peers_block.erb'),
  }

  if $collect_exported {
    haproxy::peer::collect_exported { $name: }
  }
  # else: the resources have been created and they introduced their
  # concat fragments. We don't have to do anything about them.
}
