# == Define Resource Type: pacemaker::resource::ip
#
# A resource type to create pacemaker IPaddr2 resources, provided
# for convenience.
#
# === Parameters
#
# [*name*]
# The name of the pacemaker resource, i.e. as seen in "pcs status".
#
# [*ip_address*]
# The virtual IP address you want pacemaker to create and manage.
#
# [*cidr_netmask*]
# The netmask to use in the cidr= option in the "pcs resource create"
# command. Optional.  Default is '32'.
#
# [*nic*]
# The nic to use in the nic= option in the "pcs resource create"
# command.  Optional.
#
# [*group_params*]
# Additional group parameters to pass to "pcs create", typically just
# the the name of the pacemaker resource group. Optional.
#
define pacemaker::resource::ip(
  $ensure             = 'present',
  $ip_address         = undef,
  $cidr_netmask       = '32',
  $nic                = '',
  $group_params       = '',
  $post_success_sleep = 0,
  $tries              = 1,
  $try_sleep          = 0,
  ) {

  $cidr_option = $cidr_netmask ? {
      ''      => '',
      default => " cidr_netmask=${cidr_netmask}"
  }
  $nic_option = $nic ? {
      ''      => '',
      default => " nic=${nic}"
  }

  pcmk_resource { "ip-${ip_address}":
    ensure             => $ensure,
    resource_type      => 'IPaddr2',
    resource_params    => "ip=${ip_address}${cidr_option}${nic_option}",
    group_params       => $group_params,
    post_success_sleep => $post_success_sleep,
    tries              => $tries,
    try_sleep          => $try_sleep,
  }

}
