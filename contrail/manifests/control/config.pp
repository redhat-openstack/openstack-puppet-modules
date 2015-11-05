# == Class: contrail::control::config
#
# Configure the control service
#
# === Parameters:
#
# [*secret*]
#   RNDC secret
#
# [*forwarder*]
#   (optional) Default forward DNS server
#   Defaults '8.8.8.8'
#
# [*dns_config*]
#   (optional) Hash of parameters for /etc/contrail/dns/contrail-dns.conf
#
# [*control_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-control.conf
#
# [*control_nodemgr_config*]
#   (optional) Hash of parameters for /etc/contrail/contrail-control-nodemgr.conf
#
class contrail::control::config (
  $secret,
  $forwarder              = '8.8.8.8',
  $dns_config             = {},
  $control_config         = {},
  $control_nodemgr_config = {},
) {

  include ::contrail::vnc_api
  include ::contrail::ctrl_details
  include ::contrail::service_token
  include ::contrail::keystone

  validate_hash($dns_config)
  validate_hash($control_config)
  validate_hash($control_nodemgr_config)

  create_resources('contrail_dns_config', $dns_config)
  create_resources('contrail_control_config', $control_config)
  create_resources('contrail_control_nodemgr_config', $control_nodemgr_config)

  file { '/etc/contrail/dns/contrail-named.conf' :
    ensure  => file,
    content => template('contrail/contrail-named.conf.erb'),
  }

}
