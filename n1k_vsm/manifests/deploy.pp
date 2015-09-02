# == Class: n1k_vsm::deploy
#
# This class that actually deploys a VSM VM in the server
# This depends of n1kv_vsm class to set some environmental variables
#
class n1k_vsm::deploy
{
  require n1k_vsm
  include n1k_vsm

  #ensure tap interfaces and deploy the vsm
  $ctrltap  = 'vsm-ctrl0'
  $mgmttap  = 'vsm-mgmt0'
  $pkttap   = 'vsm-pkt0'

  # Validate and get the array of digits for the vsm_mac_base (or use default)
  # Using _vmb as the name for the final string to increase readability
  $tmp_mac_base = regsubst($n1k_vsm::vsm_mac_base, '[^0-9a-fA-F]+', '')
  if (inline_template('<%= @tmp_mac_base.length %>') < 7) {
    $vmb = split('005dc79', '')
  } else {
    $vmb = split($tmp_mac_base, '')
  }

  # Generate MACs for VSM
  $ctrlmac  = "52:54:${vmb[0]}${vmb[1]}:${vmb[2]}${vmb[3]}:${vmb[4]}${vmb[5]}:${vmb[6]}1"
  $mgmtmac  = "52:54:${vmb[0]}${vmb[1]}:${vmb[2]}${vmb[3]}:${vmb[4]}${vmb[5]}:${vmb[6]}2"
  $pktmac   = "52:54:${vmb[0]}${vmb[1]}:${vmb[2]}${vmb[3]}:${vmb[4]}${vmb[5]}:${vmb[6]}3"

  exec { 'Exec_create_disk':
    command => "/usr/bin/qemu-img create -f raw ${n1k_vsm::diskfile} ${n1k_vsm::disksize}G",
    creates => $n1k_vsm::diskfile,
  }

  $targetxmlfile = "/var/spool/cisco/vsm/vsm_${n1k_vsm::vsm_role}_deploy.xml"
  file { 'File_Target_XML_File':
    path    => $targetxmlfile,
    owner   => 'root',
    group   => 'root',
    mode    => '0666',
    seltype => 'virt_content_t',
    content => template('n1k_vsm/vsm_vm.xml.erb'),
    require => Exec['Exec_create_disk'],
  }

  # Don't start VSM if this is pacemaker controlled deployment
  if !($n1k_vsm::pacemaker_control) {
    exec { 'Exec_Define_VSM':
      command => "/usr/bin/virsh define ${targetxmlfile}",
      unless  => "/usr/bin/virsh list --all | grep -c ${n1k_vsm::vsmname}",
      require => File['File_Target_XML_File'],
    }

    exec { 'Exec_Launch_VSM':
      command => "/usr/bin/virsh start ${n1k_vsm::vsmname}",
      unless  => ("/usr/bin/virsh list --all | grep ${n1k_vsm::vsmname} | grep -c running"),
      require => Exec['Exec_Define_VSM'],
    }
  } else {
    # For pacemker controlled deployment, set up the secondary VSM as well
    # ensure tap interfaces and deploy the vsm
    $ctrltap_s  = 'vsm-ctrl1'
    $mgmttap_s  = 'vsm-mgmt1'
    $pkttap_s   = 'vsm-pkt1'
    # Generate MACs
    $ctrlmac_s  = "52:54:${vmb[0]}${vmb[1]}:${vmb[2]}${vmb[3]}:${vmb[4]}${vmb[5]}:${vmb[6]}4"
    $mgmtmac_s  = "52:54:${vmb[0]}${vmb[1]}:${vmb[2]}${vmb[3]}:${vmb[4]}${vmb[5]}:${vmb[6]}5"
    $pktmac_s   = "52:54:${vmb[0]}${vmb[1]}:${vmb[2]}${vmb[3]}:${vmb[4]}${vmb[5]}:${vmb[6]}6"

    exec { 'Exec_create_disk_Secondary':
      command => "/usr/bin/qemu-img create -f raw ${n1k_vsm::diskfile_s} ${n1k_vsm::disksize}G",
      creates => $n1k_vsm::diskfile_s,
    }

    $targetxmlfile_s = "/var/spool/cisco/vsm/vsm_${n1k_vsm::vsm_role_s}_deploy.xml"
    file { 'File_Target_XML_File_Secondary':
      path    => $targetxmlfile_s,
      owner   => 'root',
      group   => 'root',
      mode    => '0666',
      seltype => 'virt_content_t',
      content => template('n1k_vsm/vsm_vm_secondary.xml.erb'),
      require => Exec['Exec_create_disk_Secondary'],
    }
  }
}
