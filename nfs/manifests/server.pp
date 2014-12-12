# == Class: nfs::server
#
# Manages an NFS Server
#
class nfs::server (
  $exports_path   = '/etc/exports',
  $exports_owner  = 'root',
  $exports_group  = 'root',
  $exports_mode   = '0644',
) inherits nfs {

  # GH: TODO - use file fragment pattern
  file { 'nfs_exports':
    ensure => file,
    path   => $exports_path,
    owner  => $exports_owner,
    group  => $exports_group,
    mode   => $exports_mode,
    notify => Exec['update_nfs_exports'],
  }

  exec { 'update_nfs_exports':
    command     => 'exportfs -ra',
    path        => '/bin:/usr/bin:/sbin:/usr/sbin',
    refreshonly => true,
  }

  Service ['nfs_service'] {
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['nfs_exports'],
  }
}
