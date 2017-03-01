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
  $vhost_ip               = '127.0.0.1',
  $discovery_ip           = '127.0.0.1',
  $device                 = 'eth0',
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

  validate_hash($vrouter_agent_config)
  validate_hash($vrouter_nodemgr_config)

  create_resources('contrail_vrouter_agent_config', $vrouter_agent_config)
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

  exec { '/bin/python /opt/contrail/utils/update_dev_net_config_files.py' :
    command => "/bin/python /opt/contrail/utils/update_dev_net_config_files.py \
                 --vhost_ip ${vhost_ip} \
                 --dev ${device} \
                 --compute_dev ${device} \
                 --netmask ${netmask} \
                 --gateway ${gateway} \
                 --cidr ${vhost_ip}/${mask} \
                 --mac ${macaddr}",
  }

}
