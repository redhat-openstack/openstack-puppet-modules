# == Class: n1k_vsm::pkgprep_ovscfg
#
# This class prepares the packages and ovs bridge for the VSM VM
#
# == Parameters:
#
# None
#
# == Actions:
#
# == Requires:
#
# This requires n1k_vsm class to set some environmental variables
#
# == Sample Usage:
#
class n1k_vsm::pkgprep_ovscfg
{
  require n1k_vsm
  include n1k_vsm

  # Definition of sync points

  $Sync_Point_KVM = '##SYNC_POINT_KVM'
  $Sync_Point_Virsh_Network = '##SYNC_POINT_VIRSH_NETWORK'

  case $::osfamily {
    'RedHat': {
      #
      # Order indepedent resources
      #
      service { 'Service_network':
        ensure  => running,
        name    => 'network',
        restart => '/sbin/service network restart || /bin/true',
      }
      ->
      exec { 'Debug_Service_network':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Service_network\n name=network\n ensure=running\n enable=true\n restart=/sbin/service network restart\n\" >> ${n1k_vsm::Debug_Log}",
      }

      #
      # VSM dependent packages installation section
      #
      package { 'Package_qemu-kvm':
        ensure => installed,
        name   => 'qemu-kvm',
        before => Notify[ $Sync_Point_KVM ],
      }
      ->
      exec { 'Debug_Package_qemu-kvm':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_qemu-kvm \n name=qemu-kvm \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }

      package {'Package_libvirt':
        ensure => installed,
        name   => 'libvirt',
        before => Notify[ $Sync_Point_KVM ],
      }
      ->
      exec { 'Debug_Package_libvirt':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_libvirt \n name=libvirt \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }

      package { 'Package_libvirt-python':
        ensure => installed,
        name   => 'libvirt-python',
        before => Notify[ $Sync_Point_KVM ],
      }
      ->
      exec { 'Debug_Package_libvirt-python':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_libvirt-python \n name=libvirt-python \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }

      package { 'Package_ebtables':
        ensure => installed,
        name   => 'ebtables',
        before => Notify[ $Sync_Point_KVM ],
      }
      ->
      exec { 'Debug_Package_ebtables':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_ebtables \n name=ebtables \n ensure=purged \n\" >> ${n1k_vsm::Debug_Log}",
      }

      notify { $Sync_Point_KVM :}

      service { 'Service_libvirtd':
        ensure => running,
        name   => 'libvirtd',
      }
      ->
      exec { 'Debug_Service_libvirtd':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Service_libvirtd\n name=libvirtd \n ensure=running \n\" >> ${n1k_vsm::Debug_Log}",
      }

      #
      # Virsh network exec configuration section
      #
      exec { 'Exec_removenet':
        command => '/usr/bin/virsh net-destroy default || /bin/true',
        unless  => '/usr/bin/virsh net-info default | /bin/grep -c \'Active: .* no\'',
        before  => Notify[ $Sync_Point_Virsh_Network ],
      }
      ->
      exec { 'Debug_Exec_removenet':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_removenet \n command=/usr/bin/virsh net-destroy default || /bin/true \n unless=/usr/bin/virsh net-info default | /bin/grep -c 'Active: .* no'\n\" >> ${n1k_vsm::Debug_Log}",
      }

      exec { 'Exec_disableautostart':
        command => '/usr/bin/virsh net-autostart --disable default || /bin/true',
        unless  => '/usr/bin/virsh net-info default | /bin/grep -c \'Autostart: .* no\'',
        before  => Notify[ $Sync_Point_Virsh_Network ],
      }
      ->
      exec { 'Debug_Exec_disableautostart':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_disableautostart \n command=/usr/bin/virsh net-autostart --disable default || /bin/true \n unless /usr/bin/virsh net-info default | grep -c 'Autostart: .* no'\" >> ${n1k_vsm::Debug_Log}",
      }

      notify{ $Sync_Point_Virsh_Network :}

      package { 'Package_openvswitch':
        ensure => installed,
        name   => 'openvswitch',
      }
      ->
      exec { 'Debug_Package_openvswitch':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_openvswitch \n name=openvswitch \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }

      #
      # bring up OVS and perform interface configuration
      #
      service { 'Service_openvswitch':
        ensure => running,
        name   => 'openvswitch',
        enable => true,
      }
      ->
      exec { 'Debug_Service_openvswitch':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Service_openvswitch \n name=openvswitch \n ensure=running \n enable=true\n\" >> ${n1k_vsm::Debug_Log}",
      }

#      exec { 'Exec_AddOvsBr':
#        command => "/usr/bin/ovs-vsctl -- --may-exist add-br ${n1k_vsm::ovsbridge}",
#      }
#      ->
#      exec { 'Debug_Exec_AddOvsBr':
#        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_AddOvsBr \n command=/usr/bin/ovs-vsctl -- --may-exist add-br ${n1k_vsm::ovsbridge} \n \" >> ${n1k_vsm::Debug_Log}",
#      }

      notify { "Debug br ${n1k_vsm::ovsbridge} intf ${n1k_vsm::phy_if_bridge} ." : withpath => true }
      notify { "Debug ${n1k_vsm::vsmname} ip ${n1k_vsm::phy_ip_addr} mask ${n1k_vsm::phy_ip_mask} gw_intf ${n1k_vsm::gw_intf}" : withpath => true }

      # Check if we've already configured the ovs
      if $n1k_vsm::gw_intf != $n1k_vsm::ovsbridge {
        #
        # Modify Ovs bridge inteface configuation file
        #
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
          #notify => Service["Service_network"],
        }
        ->
        exec { 'Debug_Augeas_modify_ifcfg-ovsbridge':
          command => "${n1k_vsm::Debug_Print} \"[INFO]\n Augeas_modify_ifcfg-${n1k_vsm::ovsbridge} \n name=${n1k_vsm::ovsbridge} \n context=/files/etc/sysconfig/network-scripts/ifcfg-${n1k_vsm::ovsbridge} \n\" >> ${n1k_vsm::Debug_Log}",
        }

        #
        # Modify Physical Interface config file
        #
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
#        ->
#        exec { 'Add default route':
#          command => "/sbin/route add default gw ${n1k_vsm::phy_gw_ip} ${n1k_vsm::ovsbridge}",
#        }
        ->
        exec { 'Debug_Augeas_modify_ifcfg-phy_if_bridge':
          command => "${n1k_vsm::Debug_Print} \"[INFO]\n Augeas_modify_ifcfg-phy_if_bridge \n name=${n1k_vsm::phy_if_bridge} \n context=/files/etc/sysconfig/network-scripts/ifcfg-${n1k_vsm::phy_if_bridge}\n\" >> ${n1k_vsm::Debug_Log}",
        }
        #
        # Make sure that networking comes fine after reboot
        #
        file { 'Create_Init_File':
          replace => 'yes',
          path    => '/etc/init.d/n1kv',
          owner   => 'root',
          group   => 'root',
          mode    => '0775',
          source  => 'puppet:///modules/n1k_vsm/n1kv',
#         content => '#!/bin/sh \n\n/etc/init.d/network restart \n/usr/lib/systemd/system/libvirtd.service restart \n\n',
        }
        ->
        exec { 'Debug_File_Init':
          command => '/usr/bin/ln -s /etc/init.d/n1kv /etc/rc.d/rc3.d/S98n1kv',
        }
      }  # endif of if "${n1k_vsm::gw_intf}" != "${n1k_vsm::ovsbridge}"

      #
      # Order enforcement logic
      #
      if $n1k_vsm::gw_intf != $n1k_vsm::ovsbridge {
        Notify[$Sync_Point_KVM]->Service['Service_libvirtd']->Notify[$Sync_Point_Virsh_Network]->Package['Package_openvswitch']->Service['Service_openvswitch']->Augeas['Augeas_modify_ifcfg-ovsbridge']->Augeas['Augeas_modify_ifcfg-phy_if_bridge']->File['Create_Init_File']
#->Exec["Exec_rebridge"]
      } else {
        Notify[$Sync_Point_KVM]->Service['Service_libvirtd']->Notify[$Sync_Point_Virsh_Network]->Package['Package_openvswitch']->Service['Service_openvswitch']
      }
    }
    'Ubuntu': {
    }
    default: {
      #
      # bail out for unsupported OS
      #
      fail("<Error>: os[${::os}] is not supported")
    }
  }
}

