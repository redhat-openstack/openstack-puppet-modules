# == Class: n1k_vsm::vsmprep
#
# This class prepares the VSM image to be deploy in a server
# This class requires n1k_vsm to set some environmental variables
#
class n1k_vsm::vsmprep
{
  include ::stdlib
  require ::n1k_vsm
  include ::n1k_vsm

  # prepare vsm folders
  ensure_resource('file', '/var/spool/cisco/', {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0664'}
  )
  ensure_resource('file', '/var/spool/cisco/vsm', {
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0664'}
  )

  #Check source of n1kv-vsm image:yum-repo (or) local file in 'files' directory
  if $n1k_vsm::n1kv_source != '' {
    if ($n1k_vsm::n1kv_source =~ /^http/) or ($n1k_vsm::n1kv_source =~ /^ftp/) {
      $vsmimage_uri = 'repo'
      $vsm_path     = '/opt/cisco/vsm'
    } else {
      $vsmimage_uri = 'file'
      $vsmtgtimg    = "/var/spool/cisco/vsm/${n1k_vsm::n1kv_source}"
      $vsm_path     = '/var/spool/cisco/vsm'
    }
  } else {
    $vsmimage_uri   = 'unspec'
    $vsm_path       = '/opt/cisco/vsm'
  }

  if $vsmimage_uri == 'file' {
    #specify location on target-host where image file will be downloaded to.
    file { $vsmtgtimg:
      owner   => 'root',
      group   => 'root',
      mode    => '0664',
      source  => "puppet:///modules/n1k_vsm/${n1k_vsm::n1kv_source}",
      require => File['/var/spool/cisco/vsm/'],
    }
  } else {
    if $vsmimage_uri == 'repo' {
      #vsm package: 'nexus-1000v-vsm' rpm will be downloaded and installed
      #from below repo.
      yumrepo { 'cisco-vsm-repo':
        baseurl  => $n1k_vsm::n1kv_source,
        descr    => 'Repo for VSM Image',
        enabled  => 1,
        gpgcheck => 1,
        gpgkey   => "${n1k_vsm::n1kv_source}/RPM-GPG-KEY",
      }
    }
    package {'nexus-1000v-iso':
        ensure   => 'present',
        name     => 'nexus-1000v-iso',
        provider => 'yum',
    }
  }

  # copy repackiso.py to local place
  file { 'VSM_Repackage_Script':
    ensure => present,
    path   => '/tmp/repackiso.py',
    owner  => 'root',
    group  => 'root',
    mode   => '0774',
    source => 'puppet:///modules/n1k_vsm/repackiso.py',
  }

  # copy the latest VSM image to known name
  if $n1k_vsm::n1kv_version == '' or $n1k_vsm::n1kv_version == 'latest'{
    exec { 'Exec_VSM_Rename':
      command => "/bin/cp ${vsm_path}/`/bin/ls ${vsm_path} | /bin/sort -r | /bin/grep -m 1 iso` ${vsm_path}/current-n1000v.iso",
      creates => "${vsm_path}/current-n1000v.iso",
    }
  } else {
    exec { 'Exec_VSM_Rename_with_version':
      command => "/bin/cp ${vsm_path}/n1000v-dk9.${n1k_vsm::n1kv_version}.iso ${vsm_path}/current-n1000v.iso",
      creates => "${vsm_path}/current-n1000v.iso",
    }
  }

  # Now generate ovf xml file and repackage the iso
  exec { 'Exec_VSM_Repackage_Script':
    command => "/tmp/repackiso.py -i${vsm_path}/current-n1000v.iso -d${n1k_vsm::vsm_domain_id} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::vsm_admin_passwd} -r${n1k_vsm::vsm_role} -f/var/spool/cisco/vsm/${n1k_vsm::vsm_role}_repacked.iso",
    creates => "/var/spool/cisco/vsm/${n1k_vsm::vsm_role}_repacked.iso",
  }

  # If we're under pacemaker_control, create a secondary VSM iso as well
  if ($n1k_vsm::pacemaker_control) {
    exec { 'Exec_VSM_Repackage_Script_secondary':
      command => "/tmp/repackiso.py -i${vsm_path}/current-n1000v.iso -d${n1k_vsm::vsm_domain_id} -n${n1k_vsm::vsmname_s} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::vsm_admin_passwd} -r${n1k_vsm::vsm_role_s} -f/var/spool/cisco/vsm/${n1k_vsm::vsm_role_s}_repacked.iso",
      creates => "/var/spool/cisco/vsm/${n1k_vsm::vsm_role_s}_repacked.iso",
    }
  }
}
