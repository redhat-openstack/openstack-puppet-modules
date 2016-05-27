# == Class: pacemaker::new::setup::debian
#
# Configure the debian/ubuntu defaults and support files
# for the cluster services.
#
class pacemaker::new::setup::debian (
  $plugin_version = $pacemaker::new::params::plugin_version,
) inherits ::pacemaker::new::params {
  validate_integer($plugin_version)

  File {
    ensure => 'present',
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { 'corosync-service-dir' :
    ensure  => 'directory',
    path    => '/etc/corosync/service.d',
    purge   => true,
    recurse => true,
  }

  file { 'corosync-service-pacemaker' :
    path    => '/etc/corosync/service.d/pacemaker',
    content => template('pacemaker/debian/pacemaker_service.erb'),
  }

  file { 'corosync-debian-default' :
    path    => '/etc/default/corosync',
    content => template('pacemaker/debian/corosync_default.erb'),
  }

  file { 'pacemaker-debian-default' :
    path    => '/etc/default/pacemaker',
    content => template('pacemaker/debian/pacemaker_default.erb'),
  }

  file { 'cman-debian-default' :
    path    => '/etc/default/cman',
    content => template('pacemaker/debian/cman_default.erb'),
  }

  File['corosync-service-pacemaker'] ~>
  Service <| tag == 'cluster-service' |>

  File['corosync-debian-default'] ~>
  Service <| tag == 'cluster-service' |>

  File['pacemaker-debian-default'] ~>
  Service <| tag == 'cluster-service' |>

  File['cman-debian-default'] ~>
  Service <| tag == 'cluster-service' |>
}