# == Class: n1k_vsm::pkgprep_ovscfg
# This class prepares the packages and ovs bridge for the VSM VM
# This requires n1k_vsm class to set some environmental variables
#
class n1k_vsm::pkgprep_ovscfg
{
  require n1k_vsm
  include n1k_vsm

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
        name   => 'qemu-kvm',
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

      package { 'Package_openvswitch':
        ensure => installed,
        name   => 'openvswitch',
      }

      # bring up OVS and perform interface configuration
      service { 'Service_openvswitch':
        ensure => running,
        name   => 'openvswitch',
        enable => true,
      }

      package { 'genisoimage':
        ensure => installed,
        name   => 'genisoimage',
      }

      notify { "Debug br ${n1k_vsm::ovsbridge} intf ${n1k_vsm::phy_if_bridge} ." : withpath => true }
      notify { "Debug ${n1k_vsm::vsmname} ip ${n1k_vsm::phy_ip_addr} mask ${n1k_vsm::phy_ip_mask} gw_intf ${n1k_vsm::gw_intf}" : withpath => true }

      # Check if we've already configured the ovs
      if $n1k_vsm::gw_intf != $n1k_vsm::ovsbridge {
        # Modify Ovs bridge inteface configuation file
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
            "set IPADDR ${n1k_vsm::phy_ip_addr}",
            "set NETMASK ${n1k_vsm::phy_ip_mask}",
            "set GATEWAY ${n1k_vsm::phy_gateway}",
            'set USERCTL no',
          ],
        }

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
            'rm IPADDR',
            'rm NETMASK',
            'rm GATEWAY',
            'set USERCTL no',
          ],
          notify  => Service['Service_network'],
        }
        # Make sure that networking comes fine after reboot
        file { 'Create_Init_File':
          replace => 'yes',
          path    => '/etc/init.d/n1kv',
          owner   => 'root',
          group   => 'root',
          mode    => '0775',
          source  => 'puppet:///modules/n1k_vsm/n1kv',
        }
      }  # endif of if "${n1k_vsm::gw_intf}" != "${n1k_vsm::ovsbridge}"
    }
    'Ubuntu': {
    }
    default: {
      # bail out for unsupported OS
      fail("<Error>: os[${::os}] is not supported")
    }
  }
}
