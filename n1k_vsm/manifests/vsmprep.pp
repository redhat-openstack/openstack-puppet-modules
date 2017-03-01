# == Class: n1k_vsm::vsmprep
#
# This class prepares the VSM image to be deploy in a server
# This class requires n1k_vsm to set some environmental variables
#
class n1k_vsm::vsmprep
{
  include 'stdlib'
  require n1k_vsm
  include n1k_vsm

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
  }

#  exec { 'Prev_VSM':
#    command => "/bin/rm -f /var/spool/cisco/vsm/* || /bin/true",
#  }

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
        ensure => $n1k_vsm::n1kv_version,
        name   => 'nexus-1000v-iso'
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

  # Now generate ovf xml file and repackage the iso
  exec { 'Exec_VSM_Repackage_Script':
    command => "/tmp/repackiso.py -i/var/spool/cisco/vsm/${n1k_vsm::n1kv_version}.iso -d${n1k_vsm::vsm_domain_id} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::vsm_admin_passwd} -r${n1k_vsm::vsm_role} -f/var/spool/cisco/vsm/${n1k_vsm::vsm_role}_repacked.iso ",
    unless  => "/usr/bin/virsh list --all | grep -c ${n1k_vsm::vsmname}",
  }

}
