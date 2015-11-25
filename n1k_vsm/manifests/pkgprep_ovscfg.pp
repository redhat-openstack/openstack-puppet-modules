# == Class: n1k_vsm::pkgprep_ovscfg
# This class prepares the packages and ovs bridge for the VSM VM
# This requires n1k_vsm class to set some environmental variables
#
class n1k_vsm::pkgprep_ovscfg
{
  require ::n1k_vsm
  include ::n1k_vsm

  case $::osfamily {
    'RedHat': {
      # Order indepedent resources
      service { 'Service_network':
        ensure  => running,
        name    => 'network',
        restart => '/sbin/service network restart || /bin/true',
      }

      # VSM dependent packages installation section
      package { 'Package_qemu-kvm':
        ensure => installed,
        name   => 'qemu-kvm-rhev',
      }

      package {'Package_libvirt':
        ensure => installed,
        name   => 'libvirt',
      }

      package { 'Package_libvirt-python':
        ensure => installed,
        name   => 'libvirt-python',
      }

      package { 'Package_ebtables':
        ensure => installed,
        name   => 'ebtables',
      }

      service { 'Service_libvirtd':
        ensure => running,
        name   => 'libvirtd',
      }

      # Virsh network exec configuration section
      exec { 'Exec_removenet':
        command => '/usr/bin/virsh net-destroy default || /bin/true',
        unless  => '/usr/bin/virsh net-info default | /bin/grep -c \'Active: .* no\'',
      }

      exec { 'Exec_disableautostart':
        command => '/usr/bin/virsh net-autostart --disable default || /bin/true',
        unless  => '/usr/bin/virsh net-info default | /bin/grep -c \'Autostart: .* no\'',
      }

      # Ensure OVS is present
      require vswitch::ovs

      package { 'genisoimage':
        ensure => installed,
        name   => 'genisoimage',
      }

      notify { "Debug br ${n1k_vsm::ovsbridge} intf ${n1k_vsm::phy_if_bridge} ." : withpath => true }

      $_ovsbridge     = regsubst($n1k_vsm::ovsbridge, '[.:-]+', '_', 'G')
      $_ovsbridge_mac = inline_template("<%= scope.lookupvar('::macaddress_${_ovsbridge}') %>")

      # Check if we've already configured the vsm bridge, skip configuration if so
      if ($_ovsbridge_mac == '') {

        #Gather info from the port/bridge including IP if needed
        $_phy_if_bridge     = regsubst($n1k_vsm::phy_if_bridge, '[.:-]+', '_', 'G')
        $_phy_ip_addr       = inline_template("<%= scope.lookupvar('::ipaddress_${_phy_if_bridge}') %>")
        if $_phy_ip_addr != '' and !($n1k_vsm::existing_bridge) {
          $phy_ip_addr      = inline_template("<%= scope.lookupvar('::ipaddress_${_phy_if_bridge}') %>")
          $phy_ip_mask      = inline_template("<%= scope.lookupvar('::netmask_${_phy_if_bridge}') %>")
          $gw_intf          = $n1k_vsm::phy_gateway

          notify {"ip ${phy_ip_addr} mask ${phy_ip_mask} gw ${n1k_vsm::phy_gateway} gw_dv ${gw_intf}" : withpath => true}

          # Modify Ovs bridge inteface configuation file (including IP)
          augeas { 'Augeas_modify_ifcfg-ovsbridge':
            name    => $n1k_vsm::ovsbridge,
            context => "/files/etc/sysconfig/network-scripts/ifcfg-${n1k_vsm::ovsbridge}",
            changes => [
              'set TYPE OVSBridge',
              "set DEVICE ${n1k_vsm::ovsbridge}",
              'set DEVICETYPE ovs',
              "set OVSREQUIRES ${n1k_vsm::ovsbridge}",
              'set NM_CONTROLLED no',
              'set BOOTPROTO none',
              'set ONBOOT yes',
              'set DEFROUTE yes',
              'set MTU 1500',
              "set NAME ${n1k_vsm::ovsbridge}",
              "set IPADDR ${phy_ip_addr}",
              "set NETMASK ${phy_ip_mask}",
              "set GATEWAY ${n1k_vsm::phy_gateway}",
              'set USERCTL no',
            ],
          }
        } elsif ($n1k_vsm::existing_bridge) {
          # Modify Ovs bridge inteface configuation file (without IP)
          augeas { 'Augeas_modify_ifcfg-ovsbridge':
            name    => $n1k_vsm::ovsbridge,
            context => "/files/etc/sysconfig/network-scripts/ifcfg-${n1k_vsm::ovsbridge}",
            changes => [
              'set TYPE OVSBridge',
              "set DEVICE ${n1k_vsm::ovsbridge}",
              'set DEVICETYPE ovs',
              "set OVSREQUIRES ${n1k_vsm::ovsbridge}",
              'set NM_CONTROLLED no',
              'set BOOTPROTO none',
              'set ONBOOT yes',
              'set DEFROUTE yes',
              'set MTU 1500',
              "set NAME ${n1k_vsm::ovsbridge}",
              'set USERCTL no',
            ],
          }
        } else {
          # Error out here due to invalid interface specification
          fail('Interface to be bridged for VSM must have IP address')
        }

        exec { 'Flap_n1kv_bridge':
          command => "/sbin/ifdown ${n1k_vsm::ovsbridge} && /sbin/ifup ${n1k_vsm::ovsbridge}",
          require => Augeas['Augeas_modify_ifcfg-ovsbridge'],
        }

        if !($n1k_vsm::existing_bridge) {
          # If there isn't an existing bridge, the interface is a port, and we
          # need to add it to vsm-br

          # Modify Physical Interface config file
          augeas { 'Augeas_modify_ifcfg-phy_if_bridge':
            name    => $n1k_vsm::phy_if_bridge,
            context => "/files/etc/sysconfig/network-scripts/ifcfg-${n1k_vsm::phy_if_bridge}",
            changes => [
              'set TYPE OVSPort',
              "set DEVICE ${n1k_vsm::phy_if_bridge}",
              'set DEVICETYPE ovs',
              "set OVS_BRIDGE ${n1k_vsm::ovsbridge}",
              'set NM_CONTROLLED no',
              'set BOOTPROTO none',
              'set ONBOOT yes',
              "set NAME ${n1k_vsm::phy_if_bridge}",
              'set DEFROUTE no',
              'set IPADDR ""',
              'rm NETMASK',
              'rm GATEWAY',
              'set USERCTL no',
            ],
          }
          exec { 'Flap_n1kv_phy_if':
            command => "/sbin/ifdown ${n1k_vsm::phy_if_bridge} && /sbin/ifup ${n1k_vsm::phy_if_bridge}",
            require => Augeas['Augeas_modify_ifcfg-phy_if_bridge'],
          }
        } else {
          # If there is an existing bridge- create patch ports to connect vsm-br to it
          exec { 'Create_patch_port_on_existing_bridge':
            command => "/bin/ovs-vsctl --may-exist add-port ${n1k_vsm::phy_if_bridge} ${n1k_vsm::phy_if_bridge}-${n1k_vsm::ovsbridge} -- set Interface ${n1k_vsm::phy_if_bridge}-${n1k_vsm::ovsbridge} type=patch options:peer=${n1k_vsm::ovsbridge}-${n1k_vsm::phy_if_bridge}",
            require => Exec['Flap_n1kv_bridge'],
          }
          exec { 'Create_patch_port_on_vsm_bridge':
            command => "/bin/ovs-vsctl --may-exist add-port ${n1k_vsm::ovsbridge} ${n1k_vsm::ovsbridge}-${n1k_vsm::phy_if_bridge} -- set Interface ${n1k_vsm::ovsbridge}-${n1k_vsm::phy_if_bridge} type=patch options:peer=${n1k_vsm::phy_if_bridge}-${n1k_vsm::ovsbridge}",
            require => Exec['Flap_n1kv_bridge'],
          }
          if ($n1k_vsm::phy_bridge_vlan > 0) and ($n1k_vsm::phy_bridge_vlan < 4096) {
            exec { 'Tag_patch_port':
              command => "/bin/ovs-vsctl set port ${n1k_vsm::phy_if_bridge}-${n1k_vsm::ovsbridge} tag=${n1k_vsm::phy_bridge_vlan}",
              require => Exec['Create_patch_port_on_existing_bridge'],
            }
          }
        }
      } # endif of if ($_ovsbridge_mac == '')
    }
    'Ubuntu': {
    }
    default: {
      # bail out for unsupported OS
      fail("<Error>: os[${::os}] is not supported")
    }
  }
}
