class n1k_vsm::deploy {

  #ensure tap interfaces and deploy the vsm

  $ctrltap = $n1k_vsm::ctrlinterface[0]
  $ctrlmac = $n1k_vsm::ctrlinterface[1]
  $ctrlbridge = $n1k_vsm::ctrlinterface[2]
  $mgmttap = $n1k_vsm::mgmtinterface[0]
  $mgmtmac = $n1k_vsm::mgmtinterface[1]
  $mgmtbridge = $n1k_vsm::mgmtinterface[2]
  $pkttap = $n1k_vsm::pktinterface[0]
  $pktmac = $n1k_vsm::pktinterface[1]
  $pktbridge = $n1k_vsm::pktinterface[2]

#  tapint {"$ctrltap":
#     bridge => $ctrlbridge,
#     ensure => present
#  }
#
#  tapint {"$mgmttap":
#     bridge => $mgmtbridge,
#     ensure => present
#  }
#
#  tapint {"$pkttap":
#     bridge => $pktbridge,
#     ensure => present
#  }

  
  $diskfile = "/var/spool/vsm/${n1k_vsm::role}_disk"

  exec { "Exec_create_disk":
    command => "/usr/bin/qemu-img create -f raw $diskfile ${n1k_vsm::disksize}G",
    unless => "/usr/bin/virsh list | grep -c ' ${n1k_vsm::vsmname} .* running'",
  }
  ->
  exec {"Debug_Exec_create_disk_debug":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nExec_create_disk /usr/bin/qemu-img create -f raw $diskfile ${n1k_vsm::disksize}G\" >> ${n1k_vsm::Debug_Log}",
  }

  $targetxmlfile = "/var/spool/vsm/vsm_${n1k_vsm::role}_deploy.xml"
  file { "File_Target_XML_File":
    path  => "$targetxmlfile",
    owner => 'root',
    group => 'root',
    mode => '666',
    content => template('n1k_vsm/vsm_vm.xml.erb'),
    require => Exec["Exec_create_disk"],
  }
  ->
  exec {"Debug_File_Target_XML_FILE":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nFile_Target_XML_File\n path=$targetxmlfile \n owner=root \n group=root \n mode=666 \n\" >> ${n1k_vsm::Debug_Log}",
  }

  exec { "Exec_Create_VSM":
         command => "/usr/bin/virsh define $targetxmlfile",
         unless => "/usr/bin/virsh list | grep -c ' ${n1k_vsm::vsmname} .* running'",
  }
  ->
  exec {"Debug_Exec_Create_VSM":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nExec_Launch_VSM \n command=/bin/echo /usr/bin/virsh define $targetxmlfile \n unless=/usr/bin/virsh list --all | grep -c ' ${n1k_vsm::vsmname} ' \" >> ${n1k_vsm::Debug_Log}",
  }

  exec { "Exec_Launch_VSM":
         command => "/usr/bin/virsh start ${n1k_vsm::vsmname}",
         unless => "/usr/bin/virsh list --all | grep -c ' ${n1k_vsm::vsmname} .* running '",
  }
  ->
  exec {"Debug_Exec_Launch_VSM":
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nExec_Launch_VSM \n command=/bin/echo /usr/bin/virsh start ${n1k_vsm::vsmname} \n unless=/usr/bin/virsh list --all | grep -c ' ${n1k_vsm::vsmname} .* running' \" >> ${n1k_vsm::Debug_Log}",
  }

  Exec["Exec_create_disk"] -> File["File_Target_XML_File"] -> Exec["Exec_Create_VSM"] -> Exec["Exec_Launch_VSM"]
}

