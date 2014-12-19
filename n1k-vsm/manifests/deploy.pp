# == Class: n1k_vsm::deploy
#
# This class that actually deploys a VSM VM in the server
#
# == Parameters:
#
# == Actions:
#
# == Requires:
#
# This depends of n1kv_vsm class to set some environmental variables
#
# == Sample Usage:
#
class n1k_vsm::deploy
{
  #ensure tap interfaces and deploy the vsm
  $ctrltap = 'vsm-ctrl0'
  $mgmttap = 'vsm-mgmt0'
  $pkttap = 'vsm-pkt0'

  #$diskfile = "/var/spool/vsm/${n1k_vsm::vsm_role}_disk"

  exec { 'Exec_create_disk':
    command => "/usr/bin/qemu-img create -f raw ${n1k_vsm::diskfile} ${n1k_vsm::disksize}G",
    unless  => "/usr/bin/virsh list | grep -c ' ${n1k_vsm::vsmname} .* running'",
  }
  ->
  exec { 'Debug_Exec_create_disk_debug':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nExec_create_disk /usr/bin/qemu-img create -f raw ${n1k_vsm::diskfile} ${n1k_vsm::disksize}G\" >> ${n1k_vsm::Debug_Log}",
  }

  $targetxmlfile = "/var/spool/vsm/vsm_${n1k_vsm::vsm_role}_deploy.xml"
  file { 'File_Target_XML_File':
    path    => $targetxmlfile,
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    content => template('n1k_vsm/vsm_vm.xml.erb'),
    require => Exec['Exec_create_disk'],
  }
  ->
  exec { 'Debug_File_Target_XML_FILE':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nFile_Target_XML_File\n path=${targetxmlfile} \n owner=root \n group=root \n mode=666 \n\" >> ${n1k_vsm::Debug_Log}",
  }

  exec { 'Exec_Create_VSM':
    command => "/usr/bin/virsh define ${targetxmlfile} && /usr/bin/virsh autostart ${n1k_vsm::vsmname}",
    unless  => "/usr/bin/virsh list | grep -c ' ${n1k_vsm::vsmname} '",
  }
  ->
  exec { 'Debug_Exec_Create_VSM':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nExec_Launch_VSM \n command=/bin/echo /usr/bin/virsh define ${targetxmlfile} \n unless=/usr/bin/virsh list --all | grep -c ' ${n1k_vsm::vsmname} ' \" >> ${n1k_vsm::Debug_Log}",
  }

  exec { 'Exec_Launch_VSM':
    command => "/usr/bin/virsh start ${n1k_vsm::vsmname}",
    unless  => "/usr/bin/virsh list --all | grep -c ' ${n1k_vsm::vsmname} .* running '",
  }
  ->
  exec { 'Debug_Exec_Launch_VSM':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\nExec_Launch_VSM \n command=/bin/echo /usr/bin/virsh start ${n1k_vsm::vsmname} \n unless=/usr/bin/virsh list --all | grep -c ' ${n1k_vsm::vsmname} .* running' \" >> ${n1k_vsm::Debug_Log}",
  }

  Exec['Exec_create_disk'] -> File['File_Target_XML_File'] -> Exec['Exec_Create_VSM'] -> Exec['Exec_Launch_VSM']
}
