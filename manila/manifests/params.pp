#
class manila::params {

  $manila_conf = '/etc/manila/manila.conf'
  $manila_paste_api_ini = '/etc/manila/api-paste.ini'

  if $::osfamily == 'Debian' {
    $package_name                = 'manila-common'
    $client_package              = 'python-manilaclient'
    $api_package                 = 'manila-api'
    $api_service                 = 'manila-api'
    $scheduler_package           = 'manila-scheduler'
    $scheduler_service           = 'manila-scheduler'
    $share_package               = 'manila-share'
    $share_service               = 'manila-share'
    $db_sync_command             = 'manila-manage db sync'
    $tgt_package_name            = 'tgt'
    $tgt_service_name            = 'tgt'
    $ceph_init_override          = '/etc/init/manila-share.override'
    $iscsi_helper                = 'tgtadm'
    $lio_package_name            = 'targetcli'
    $gluster_client_package_name = 'glusterfs-client'
    $gluster_package_name        = 'glusterfs-common'
    $sqlite_package_name         = 'python-pysqlite2'

  } elsif($::osfamily == 'RedHat') {

    $package_name                = 'openstack-manila'
    $client_package              = 'python-manilaclient'
    $api_package                 = false
    $api_service                 = 'openstack-manila-api'
    $scheduler_package           = false
    $scheduler_service           = 'openstack-manila-scheduler'
    $share_package               = 'openstack-manila-share'
    $share_service               = 'openstack-manila-share'
    $db_sync_command             = 'manila-manage db sync'
    $tgt_package_name            = 'scsi-target-utils'
    $tgt_service_name            = 'tgtd'
    $ceph_init_override          = '/etc/sysconfig/openstack-manila-share'
    $lio_package_name            = 'targetcli'
    $gluster_client_package_name = 'glusterfs-fuse'
    $gluster_package_name        = 'glusterfs'
    $sqlite_package_name         = undef

    if $::operatingsystem == 'RedHat' and (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
      $iscsi_helper = 'lioadm'
    } else {
      $iscsi_helper = 'tgtadm'
    }

  } else {
    fail("unsupported osfamily ${::osfamily}, currently Debian and Redhat are the only supported platforms")
  }
}
