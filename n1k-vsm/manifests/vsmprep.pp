# == Class: n1k_vsm::vsmprep
#
# This class prepares the VSM image to be deploy in a server
#
# == Parameters:
#
# None
#
# == Actions:
#
# == Requires:
#
# This class requires n1kv_vsm to set some environmental variables
#
# == Sample Usage:
#
class n1k_vsm::vsmprep
{
  include 'stdlib'
  require n1k_vsm
  include n1k_vsm

  #
  # VSM package source parsing logic
  #
  $source = $n1k_vsm::n1kv_source

  $sourcemethod = regsubst($source, '^(.+):.*', '\1')
  $dest = inline_template('<%= File.basename(source) %>')


  $VSM_Bin_Prepare_Sync_Point='##VSM_BIN_PREPARE_SYNC_POINT'
  $VSM_Spool_Dir='/var/spool/cisco/vsm'
  $VSM_RPM_Install_Dir='/opt/cisco/vsm'
  $VSM_Repackage_Script_Name='repackiso.py'
  $VSM_Repackage_Script="/tmp/${VSM_Repackage_Script_Name}"
  $VSM_DEST="${VSM_Spool_Dir}/${dest}"
  $VSM_PKG_NAME='nexus-1000v-vsm'
  $VSM_ISO='vsm.iso'

  #
  # prepare vsm folders
  #
  file { 'File_VSM_Spool_Dir':
    ensure => directory,
    path   => $VSM_Spool_Dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0664',
  }
  ->
  exec { 'Debug_File_VSM_Spool_Dir':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n File_VSM_Spool_Dir\n path=${VSM_Spool_Dir} \n ensure=directory \n owner=root \n group=root \n mode=664 \n\" >> ${n1k_vsm::Debug_Log}",
  }

  file { 'File_VSM_RPM_Dir':
    ensure => directory,
    path   => $VSM_RPM_Install_Dir,
    owner  => 'root',
    group  => 'root',
    mode   => '0664',
  }
  ->
  exec { 'Debug_File_VSM_RPM_Dir':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n File_VSM_RPM_Install_Dir\n path=${VSM_RPM_Install_Dir} \n ensure=directory \n owner=root \n group=root \n mode=664 \n\" >> ${n1k_vsm::Debug_Log}",
  }

  case $sourcemethod {
    http: {
      yumrepo { 'http-cisco-foreman':
        baseurl  => $n1k_vsm::n1kv_source,
        descr    => 'Internal repo for Foreman',
        enabled  => 1,
        gpgcheck => 1,
        proxy    => '_none_',
        gpgkey   => "${n1k_vsm::n1kv_source}/RPM-GPG-KEY",
      }
      ->
      package { 'Package_VSM':
        ensure => $n1k_vsm::n1kv_version,
        name   => $VSM_PKG_NAME,
      }
      ->
      exec { 'Copy_VSM':
        command => "/bin/cp ${VSM_RPM_Install_Dir}/*.iso ${VSM_Spool_Dir}/${VSM_ISO}",
        before  => Notify[ $VSM_Bin_Prepare_Sync_Point ],
      }
      ->
      exec { 'Debug-http-cisco-os and Package_VSM':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Debug-http-cisco-os and Package_VSM \n baseurl=${n1k_vsm::n1kv_source} \n descr=>Internal repo for Foreman \n enabled = 1 \n gpgcheck=1 \n gpgkey => ${n1kv_source::n1kv_source}/RPM-GPG-KEY\n\" >> ${n1k_vsm::Debug_Log}",
      }
    }

    ftp: {
      package { 'ftp':
        ensure => installed,
        name   => 'ftp',
      }
      ->
      yumrepo { 'ftp-cisco-foreman':
        baseurl  => $n1k_vsm::n1kv_source,
        descr    => 'Internal repo for Foreman',
        enabled  => 1,
        gpgcheck => 1,
        proxy    => '_none_',
        gpgkey   => "${n1k_vsm::n1kv_source}/RPM-GPG-KEY",
      }
      ->
      package { 'Package_VSM':
        ensure => $n1k_vsm::n1kv_version,
        name   => $VSM_PKG_NAME,
      }
      ->
      exec { 'Copy_VSM':
          command => "/bin/cp ${VSM_RPM_Install_Dir}/*.iso ${VSM_Spool_Dir}/${VSM_ISO}",
          before  => Notify[ $VSM_Bin_Prepare_Sync_Point ],
      }
      ->
      exec { 'Debug-ftp-cisco-os and Package_VSM':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Debug-ftp-cisco-os and Package_VSM \n baseurl=${n1k_vsm::n1kv_source} \n descr=>Internal repo for Foreman \n enabled = 1 \n gpgcheck=1 \n gpgkey => ${n1kv_source::n1kv_source}/RPM-GPG-KEY\n\" >> ${n1k_vsm::Debug_Log}",
      }

    }
    puppet: {
      #
      # make sure the file does not exist
      #
      exec { 'File_VSM_Bin_Remove':
        command => "/bin/rm -f ${VSM_DEST} || /bin/true",
        before  => Notify[ $VSM_Bin_Prepare_Sync_Point ],
      }
      ->
      file { 'File_VSM_Bin_Prepare':
        ensure => present,
        path   => $VSM_DEST,
        owner  => 'root',
        group  => 'root',
        mode   => '0664',
        source => $n1k_vsm::n1kv_source,
        before => Notify[ $VSM_Bin_Prepare_Sync_Point ],
      }
      ->
      exec { 'Exec_RPM_TO_ISO':
        #
        # If it's an RPM, we do a local rpm installation ..."
        #
        command => "/bin/rpm -i --force ${VSM_DEST} && /bin/cp ${VSM_RPM_Install_Dir}/*.iso ${VSM_Spool_Dir}/${VSM_ISO}",
        unless  => '/usr/bin/file $VSM_DEST | /bin/grep -c \' ISO \'',
        before  => Notify[ $VSM_Bin_Prepare_Sync_Point],
      }
      ->
      exec { 'Debug_File_VSM_Bin_Prepare_Exec_RPM_TO_ISO':
        command => "${n1k_vsm::Debug_Print} \"[INFO]\n Debug_File_VSM_Bin_Prepare_Exec_RPM_TO_ISO \n path=${VSM_DEST} \n ensure=directory \n owner=root\n group=root\n mode=664\n source=${n1k_vsm::n1kv_source}\n \" >> ${n1k_vsm::Debug_Log}",
      }
    }
    default: {
      fail("<Error>: Unknown sourcing method [${sourcemethod}] is not supported")
    }
  }

  notify { $VSM_Bin_Prepare_Sync_Point :}

  #
  # copy repackiso.py to local place
  #
  file { 'File_VSM_Repackage_Script_Name':
    ensure => present,
    path   => $VSM_Repackage_Script,
    owner  => 'root',
    group  => 'root',
    mode   => '0774',
    source => "puppet:///modules/n1k_vsm/${VSM_Repackage_Script_Name}",
  }
  ->
  exec { 'Debug_File_VSM_Repackage_Script_Name':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Debug_VSM_Repackage_Script_Name \n path=${VSM_Repackage_Script} \n ensure=present \n owner=root \n group=root \n mode=774\n source=puppet:///modules/n1k_vsm/${VSM_Repackage_Script_Name} \n\" >> ${n1k_vsm::Debug_Log}",
  }

  #
  # Now generate ovf xml file and repackage the iso
  #
  exec { 'Exec_VSM_Repackage_Script_Name':
    command => "${VSM_Repackage_Script} -i${VSM_Spool_Dir}/${VSM_ISO} -d${n1k_vsm::vsm_domain_id} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::vsm_admin_passwd} -r${n1k_vsm::vsm_role} -f${VSM_Spool_Dir}/${n1k_vsm::vsm_role}_repacked.iso >> ${n1k_vsm::Debug_Log}",
  }
  ->
  exec { 'Debug_Exec_VSM_Repackage_Script_Name':
    command => "${n1k_vsm::Debug_Print} \"[INFO]\n Exec_VSM_Repackage_Script_Name\n command=${VSM_Repackage_Script} -i${VSM_ISO} -d${n1k_vsm::vsm_domain_id} -n${n1k_vsm::vsmname} -m${n1k_vsm::mgmtip} -s${n1k_vsm::mgmtnetmask} -g${n1k_vsm::mgmtgateway} -p${n1k_vsm::vsm_admin_passwd} -r${n1k_vsm::vsm_role} -f${VSM_Spool_Dir}/${n1k_vsm::vsm_role}_repacked.iso \n\" >> ${n1k_vsm::Debug_Log}"
  }

  File['File_VSM_Spool_Dir']->File['File_RPM_Install_Dir']->Notify[$VSM_Bin_Prepare_Sync_Point]->File['File_VSM_Repackage_Script_Name']->Exec['Exec_VSM_Repackage_Script_Name']

}
