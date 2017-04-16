class n1k_vsm::pkgprep_ovscfg {

  # Definition of sync points
  
  $Sync_Point_KVM = "##SYNC_POINT_KVM"
  $Sync_Point_Virsh_Network = "##SYNC_POINT_VIRSH_NETWORK"

  case "$::osfamily"  {
    "RedHat": {
      #
      # Order indepedent resources  
      #
      service {"Service_network":
        name   => "network",
        ensure => "running",
        restart => "/sbin/service network restart || /bin/true",
      }
      ->
      exec {"Debug_Service_network":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Service_network\n name=network\n ensure=running\n enable=true\n restart=/sbin/service network restart\n\" >> ${n1k_vsm::Debug_Log}",
      }
      # VSM dependent packages installation section
      #
      # Eng note
      # cwchang: Ideally we should have either of this logic
      # 1. Have an iteration thru the package list in the $pkgs.each ...
      #    Somehow this syntax needs to turn on future parser by document
      # 2. package resource should be able to run a name list 
      # Neither one works. We go for rudimentary one-by-one here for now.
      # Pitfalls observed:
      # 1. We cannot reassign variables for some reason
      # 2. We cannot leave spaces in name
      # qemu-kvm-rhev
      package {"Package_qemu-kvm":
        name   => "qemu-kvm",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      exec {"Debug_Package_qemu-kvm":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_qemu-kvm \n name=qemu-kvm \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }

      package {"Package_virt-viewer":
        name   => "virt-viewer",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      exec {"Debug_Package_virt-viewer": 
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_virt-viewer \n name=virt-viewer \n ensure=installed \n\" >> ${n1k_vsm::Debug_Log}",
      }
    
      package {"Package_virt-manager":
        name   => "virt-manager",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      exec {"Debug_Package_virt-manager": 
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_virt-manager \n name=virt-manager \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }
    
      package {"Package_libvirt":
        name   => "libvirt",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      exec {"Debug_Package_libvirt": 
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_libvirt \n name=libvirt \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }
    
      package {"Package_libvirt-python":
        name   => "libvirt-python",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      exec {"Debug_Package_libvirt-python": 
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_libvirt-python \n name=libvirt-python \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }
    
      #package {"Package_python-virtinst":
      #  name   => "python-virtinst",
      #  ensure => "installed",
      #  before => Notify["$Sync_Point_KVM"],
      #}
      #->
      #exec {"Debug_Package_python-virtinst": 
      #  command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_python-virtinst \n name=python-virtinst \n ensure=installed \n\" >> ${n1k_vsm::Debug_Log}",
      #}

      #package {"Package_genisoimage":
      #  name   => "genisoimage",
      #  ensure => "installed",
      #  before => Notify["$Sync_Point_KVM"],
      #}
      #->
      #exec {"Debug_Package_genisoimage": 
      #  command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_genisoimage \n name=genisoimage \n ensure=installed \n\" >> ${n1k_vsm::Debug_Log}",
      #}

      package {"Package_ebtables":
        name   => "ebtables",
        #ensure => "purged",
        ensure => "installed",
        before => Notify["$Sync_Point_KVM"],
      }
      ->
      exec {"Debug_Package_ebtables":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_ebtables \n name=ebtables \n ensure=purged \n\" >> ${n1k_vsm::Debug_Log}",
      }

      notify{"$Sync_Point_KVM":}

      service {"Service_libvirtd":
        name   => "libvirtd",
        ensure => "running",
      }
      ->
      exec {"Debug_Service_libvirtd":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Service_libvirtd\n name=libvirtd \n ensure=running \n\" >> ${n1k_vsm::Debug_Log}",
      }
         
      #
      # Virsh network exec configuration section 
      #
      exec {"Exec_removenet":
        command => "/usr/bin/virsh net-destroy default || /bin/true",
        unless => "/usr/bin/virsh net-info default | /bin/grep -c 'Active: .* no'",
        before => Notify["$Sync_Point_Virsh_Network"],
      }
      ->
      exec {"Debug_Exec_removenet":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_removenet \n command=/usr/bin/virsh net-destroy default || /bin/true \n unless=/usr/bin/virsh net-info default | /bin/grep -c 'Active: .* no'\n\" >> ${n1k_vsm::Debug_Log}",
      }

      exec {"Exec_disableautostart":
        command => "/usr/bin/virsh net-autostart --disable default || /bin/true",
        unless => "/usr/bin/virsh net-info default | /bin/grep -c 'Autostart: .* no'",
        before => Notify["$Sync_Point_Virsh_Network"],
      }
      ->
      exec {"Debug_Exec_disableautostart":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_disableautostart' \n command=/usr/bin/virsh net-autostart --disable default || /bin/true \n unless /usr/bin/virsh net-info default | grep -c 'Autostart: .* no'\" >> ${n1k_vsm::Debug_Log}",
      }
    
      notify{"$Sync_Point_Virsh_Network":}

      package {"Package_openvswitch":
        name   => "openvswitch",
        ensure => "installed",
      }
      ->
      exec {"Debug_Package_openvswitch": 
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Package_openvswitch \n name=openvswitch \n ensure=installed\n\" >> ${n1k_vsm::Debug_Log}",
      }
      # 
      # bring up OVS and perform interface configuration 
      # 

      service {"Service_openvswitch":
        name   => "openvswitch",
        ensure => "running",
        enable => "true",
      }
      ->
      exec {"Debug_Service_openvswitch": 
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Service_openvswitch \n name=openvswitch \n ensure=running \n enable=true\n\" >> ${n1k_vsm::Debug_Log}",
      }

    
      exec {"Exec_AddOvsBr":
        command => "/usr/bin/ovs-vsctl -- --may-exist add-br $n1k_vsm::ovsbridge",
      }
      ->
      exec {"Debug_Exec_AddOvsBr":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_AddOvsBr \n command=/usr/bin/ovs-vsctl -- --may-exist add-br $n1k_vsm::ovsbridge \n \" >> ${n1k_vsm::Debug_Log}",
      }

      #
      # Modify Ovs bridge inteface configuation file
      #
      augeas {"Augeas_modify_ifcfg-ovsbridge":
        name => "$n1k_vsm::ovsbridge",
        context => "/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::ovsbridge",
        changes => [
          "set DEVICE $n1k_vsm::ovsbridge", 
          "set BOOTPROTO none",
          "set IPADDR $n1k_vsm::nodeip",
          "set NETMASK $n1k_vsm::nodenetmask",
          "set ONBOOT yes",
          "set TYPE OVSBridge",
          "set DEVICETYPE ovs",
        ],
        notify => Service["Service_network"],
      }
      ->
      exec {"Debug_Augeas_modify_ifcfg-ovsbridge":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Augeas_modify_ifcfg-$n1k_vsm::ovsbridge \n name=$n1k_vsm::ovsbridge \n context=/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::ovsbridge \n\" >> ${n1k_vsm::Debug_Log}",
      }

      #
      # Modify Physical Interface config file
      #
      augeas {"Augeas_modify_ifcfg-physicalinterfaceforovs":
        name => "$n1k_vsm::physicalinterfaceforovs",
        context => "/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::physicalinterfaceforovs",
        changes => [
          "set ONBOOT yes",
          "set BOOTPROTO none",
          "set TYPE OVSPort",
          "set DEVICETYPE ovs",
          "set OVS_BRIDGE $n1k_vsm::ovsbridge",
          "rm IPADDR",
          "rm NETMASK",
        ],
      }
      ->
      exec {"Debug_Augeas_modify_ifcfg-physicalinterfaceforovs":
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Augeas_modify_ifcfg-physicalinterfaceforovs \n name=$n1k_vsm::physicalinterfaceforovs \n context=/files/etc/sysconfig/network-scripts/ifcfg-$n1k_vsm::physicalinterfaceforovs\n\" >> ${n1k_vsm::Debug_Log}",
      }

      $intf=$n1k_vsm::physicalinterfaceforovs
      $phy_bridge="/tmp/phy_bridge"
      #
      # Move physical port around from host bridge if any, to ovs bridge
      #
      #exec {"Exec_phy_bridge":
      #  command => "/usr/sbin/brctl show | /bin/grep $intf | /bin/sed 's/[\t ].*//' > $phy_bridge", 
      #}
      #->
      #exec {"Debug_Exec_phy_bridge":
      #  command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_phy_bridge \n /usr/sbin/brctl show | /bin/grep $intf | /bin/sed 's/[\t ].*//' > $phy_bridge \n \" >> ${n1k_vsm::Debug_Log}", 
      #}
  
      exec {"Exec_rebridge":
        #command => "/usr/bin/test -s $phy_bridge && /usr/sbin/brctl delif \$(cat $phy_bridge) $intf || /bin/true; /usr/bin/ovs-vsctl -- --may-exist add-port $n1k_vsm::ovsbridge $intf",
        command => "/usr/bin/ovs-vsctl -- --may-exist add-port $n1k_vsm::ovsbridge $intf",
        #notify => Service["Service_network"],
      }
      ->
      exec {"Debug_Exec_rebridge":
        #command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_rebridge \n /usr/bin/test -s $phy_bridge && /usr/sbin/brctl delif \$(cat $phy_bridge) $intf || /bin/true; /usr/bin/ovs-vsctl -- --may-exist add-port $n1k_vsm::ovsbridge $intf; /bin/rm -f $phy_bridge \n\" >> ${n1k_vsm::Debug_Log}",
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_rebridge \n /usr/bin/ovs-vsctl -- --may-exist add-port $n1k_vsm::ovsbridge $intf \n\" >> ${n1k_vsm::Debug_Log}",
      }

      #
      # Order enforcement logic
      # 
      #Notify["$Sync_Point_KVM"] -> Service["Service_libvirtd"] -> Notify["$Sync_Point_Virsh_Network"] -> Package["Package_openvswitch"] -> Service["Service_openvswitch"] -> Exec["Exec_AddOvsBr"]->Augeas["Augeas_modify_ifcfg-ovsbridge"]->Augeas["Augeas_modify_ifcfg-physicalinterfaceforovs"]->Exec["Exec_phy_bridge"]->Exec["Exec_rebridge"]
      Notify["$Sync_Point_KVM"] -> Service["Service_libvirtd"] -> Notify["$Sync_Point_Virsh_Network"] -> Package["Package_openvswitch"] -> Service["Service_openvswitch"] -> Exec["Exec_AddOvsBr"]->Augeas["Augeas_modify_ifcfg-ovsbridge"]->Augeas["Augeas_modify_ifcfg-physicalinterfaceforovs"]->Exec["Exec_rebridge"]
    }
    "Ubuntu": {
    }
    default: {
      #
      # bail out for unsupported OS
      #
      fail("<Error>: os[$os] is not supported")
    }
  }
}
