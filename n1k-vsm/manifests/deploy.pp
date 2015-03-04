# == Class: n1k_vsm::deploy
#
# This class that actually deploys a VSM VM in the server
# This depends of n1kv_vsm class to set some environmental variables
#
class n1k_vsm::deploy
{
  #ensure tap interfaces and deploy the vsm
  $ctrltap  = 'vsm-ctrl0'
  $mgmttap  = 'vsm-mgmt0'
  $pkttap   = 'vsm-pkt0'

  exec { 'Exec_create_disk':
    command => "/usr/bin/qemu-img create -f raw ${n1k_vsm::diskfile} ${n1k_vsm::disksize}G",
    unless  => "/usr/bin/virsh list --all | grep -c ${n1k_vsm::vsmname}",
  }

  $targetxmlfile = "/var/spool/cisco/vsm/vsm_${n1k_vsm::vsm_role}_deploy.xml"
  file { 'File_Target_XML_File':
    path    => $targetxmlfile,
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    content => template('n1k_vsm/vsm_vm.xml.erb'),
    require => Exec['Exec_create_disk'],
  }

  exec { 'Exec_Define_VSM':
    command => "/usr/bin/virsh define ${targetxmlfile}",
    unless  => "/usr/bin/virsh list --all | grep -c ${n1k_vsm::vsmname}",
  }

  exec { 'Exec_Launch_VSM':
    command => "/usr/bin/virsh start ${n1k_vsm::vsmname}",
    unless  => "/usr/bin/virsh list --all | grep ${n1k_vsm::vsmname} | grep -c running",
  }

  Exec['Exec_create_disk'] -> File['File_Target_XML_File'] -> Exec['Exec_Define_VSM'] -> Exec['Exec_Launch_VSM']
}
