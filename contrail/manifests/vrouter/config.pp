# == Class: contrail::vrouter::config
#
# Configure the vrouter service
#
# === Parameters:
#
# [*vhost_ip*]
#   (optional) IP of the vrouter agent
#   Defaults to '127.0.0.1'
#
# [*discovery_ip*]
#   (optional) IP of the discovery service
#   Defaults to '127.0.0.1'
#
# [*device*]
#   (optional) Network device
#   Defaults to 'eth0'
#
# [*kmod_path*]
#   (optional) full path for vrouter.ko
#   Defaults to '/lib/modules/${::kernelrelease}/extra/net/vrouter/vrouter.ko
#
# [*compute_device*]
#   (optional) Network device for Openstack compute
#   Defaukts to 'eth0;
#
# [*mask*]
#   (optional) Netmask in CIDR form
#   Defaults '24'
#
# [*netmask*]
#   (optional) Full netmask
#   Defaults '255.255.255.0'
#
# [*gateway*]
#   (optional) Gateway IP address
#   Defaults to '127.0.0.1'
#
# [*vgw_public_subnet*]
#   (optional) Virtual Gateway public subnet
#   Defaults to undef
#
# [*vgw_interface*]
#   (optional) Virtual Gateway interface
#   Defaults to undef
#
# [*macaddr*]
#   (optional) Mac address
#   Defaults to $::macaddr
#
# [*vrouter_agent_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-vrouter-agent.conf
#   Defaults {}
#
# [*vrouter_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-vrouter-nodemgr.conf
#   Defaults {}
#
class contrail::vrouter::config (
  $vhost_ip               = $::ipaddress_eth1,
  $discovery_ip           = '127.0.0.1',
  $device                 = 'eth0',
  $kmod_path              = "/lib/modules/${::kernelrelease}/extra/net/vrouter/vrouter.ko",
  $compute_device         = 'eth0',
  $mask                   = '24',
  $netmask                = '255.255.255.0',
  $gateway                = '127.0.0.1',
  $vgw_public_subnet      = undef,
  $vgw_interface          = undef,
  $macaddr                = $::macaddress,
  $vrouter_agent_config   = {},
  $vrouter_nodemgr_config = {},
) {

  include ::contrail::vnc_api
  include ::contrail::ctrl_details
  include ::contrail::service_token

  $ip_to_steal = getvar(regsubst("ipaddress_${compute_device}", '[.-]', '_', 'G'))
  $control_network_dev = { 
    'NETWORKS/control_network_ip' => { value => ${ip_to_steal} },
    'VIRTUAL-HOST-INTERFACE/ip'   => { value => "${ip_to_steal}/{$mask}" }
  }
  $new_vrouter_agent_config = merge($vrouter_agent_config, $control_network_dev)

  validate_hash($vrouter_nodemgr_config)

  create_resources('contrail_vrouter_agent_config', $new_vrouter_agent_config)
  create_resources('contrail_vrouter_nodemgr_config', $vrouter_nodemgr_config)

  file { '/etc/contrail/agent_param' :
    ensure  => file,
    content => template('contrail/vrouter/agent_param.erb'),
  }

  file { '/etc/contrail/default_pmac' :
    ensure  => file,
    content => $macaddr,
  }

  file { '/etc/contrail/vrouter_nodemgr_param' :
    ensure  => file,
    content => "DISCOVERY=${discovery_ip}",
  }

  anchor { 'vrouter::config::begin': } ->
  anchor { 'vrouter::config::end': }

  exec { 'update-net-config':
    path      => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin', ],
    command   => "python /opt/contrail/utils/update_dev_net_config_files.py \
                   --vhost_ip ${ip_to_steal} \
                   --dev ${device} \
                   --compute_dev ${device} \
                   --netmask ${netmask} \
                   --gateway ${gateway} \
                   --cidr ${vhost_ip}/${mask} \
                   --mac ${macaddr}",
    creates   => '/etc/sysconfig/network-scripts/ifcfg-vhost0',
    subscribe => Anchor['vrouter::config::begin'],
    notify    => Anchor['vrouter::config::end'],
  } ~>
  exec { 'backup-eth-ifcfg':
    path        => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin', ],
    command     => "cp /etc/sysconfig/network-scripts/ifcfg-${compute_device} /etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave",
    unless      => "grep -q IPADDR /etc/sysconfig/network-scripts/ifcfg-${compute_device}",
    creates     => "/etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave",
    logoutput   => 'on_failure',
    refreshonly => true,
  } 

  exec { 'restore-eth-ifcfg':
    path      => [ '/usr/bin', '/usr/sbin', '/bin', '/sbin', ],
    command   => "cp /etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave /etc/sysconfig/network-scripts/ifcfg-${compute_device}",
    onlyif    => [ "grep IPADDR /etc/sysconfig/network-scripts/ifcfg-${compute_device}",
                   "test -f /etc/sysconfig/network-scripts/ifcfg-${compute_device}.contrailsave",
                   'test -f /etc/sysconfig/network-scripts/ifcfg-vhost0' ],
    logoutput => 'on_failure',
    subscribe => Anchor['vrouter::config::begin'],
    notify    => Anchor['vrouter::config::end'],
  } 

  Service<| title == 'supervisor-vrouter' |> {
    restart => "systemctl stop supervisor-vrouter; \
                rmmod vrouter; \
                ifdown ${compute_device}; \
                ifup ${compute_device}; \
                systemctl start supervisor-vrouter",
    stop    => "systemctl stop supervisor-vrouter; \
                rmmod vrouter;", #TODO: not sure if should ifdown
  }

  # we should only restart the service after the ip config dance
  Anchor['vrouter::config::end'] ~> Service['supervisor-vrouter']

}
