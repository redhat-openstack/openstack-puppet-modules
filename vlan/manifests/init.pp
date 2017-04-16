# Class: vlan
#
# This module adds a vlan
class vlan(
  $interface,
  $vlan
) {

  $vlanname = "$interface.$vlan"
 
  service {'network': }
 
  file { "/etc/sysconfig/network-scripts/ifcfg-$vlanname":
    content => template('vlan/ifcfg.erb'),
    mode    => '0644',
    notify => Service['network']
  }

}
