# Install and configure libvirt.
#
# == Parameters
#
# These two parameters are used for configuring various configuration files
# that libvirt uses.
#
# [libvirtd_config]
#   *Optional* A hash for creating libvirt::libvirtd_config resources.
# [qemu_config]
#   *Optional* A hash for creating libvirt::qemu_config resources.
#
# These parameters are usually worked out automatically and can usually be
# left as they are.
#
# [package]
#   *Optional* Package(s) for installing libvirt.
# [version]
#   *Optional* Version for the libvirt package.
# [service]
#   *Optional* Service(s) for stopping and starting the libvirtd process.
# [user]
#   *Optional* User that libvirtd runs as.
# [group]
#   *Optional* Group that libvirtd runs as.
# [config_dir]
#   *Optional* Path to libvirt configuration.
# [libvirtd_config_file]
#   *Optional* Path to the libvirtd configuration file.
# [qemu_config_file]
#   *Optional* Path to the qemu configuration file for libvirtd.
#
# == Variables
#
# N/A
#
# == Examples
#
# Default configuration:
#     
#     class { "libvirt": }
#
# Custom libvirtd configuration:
#
#     class { "libvirt":
#       libvirtd_config => {
#         max_clients => { value => 10 },
#       },
#       qemu_config => {
#         vnc_listen => { value => $ipaddress },
#       },
#     }
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class libvirt (

  $package = $libvirt::params::libvirt_package,
  $version = $libvirt::params::libvirt_version,
  $service = $libvirt::params::libvirt_service,
  $user = $libvirt::params::libvirt_user,
  $group = $libvirt::params::libvirt_group,
  $libvirtd_config = undef,
  $config_dir = $libvirt::params::libvirt_config_dir,
  $libvirtd_config_file = $libvirt::params::libvirtd_config_file,
  $qemu_config_file = $libvirt::params::qemu_config_file,
  $qemu_config = undef

  ) inherits libvirt::params {

  ##############################
  # Base packages and service  #
  ##############################
  package { $package:
    ensure => $version
  }
  service { $service:
    ensure => running,
    enable => true,
    hasstatus => true,
    hasrestart => true,
  }

  ########################
  # libvirtd.conf Config #
  ########################
  file { "${config_dir}/libvirtd.d":
    ensure => directory,
    purge => true,
    recurse => true,
    require => Package[$package],
    notify => Exec["create_libvirtd_conf"],
  }
  file { "${config_dir}/libvirtd.d/00-header":
    content => "# Managed by puppet\n",
    require => Package[$package],
    notify => Exec["create_libvirtd_conf"],
  }
  exec { "create_libvirtd_conf":
    command => "/bin/cat ${config_dir}/libvirtd.d/* > ${libvirtd_config_file}",
    refreshonly => true,
    require => [ Package[$package], File["${config_dir}/libvirtd.d"] ],
    notify => Service[$service],
  }
  file { $libvirtd_config_file:
    owner => root,
    group => root,
    mode => "0644",
    require => Package[$package],
  }
  create_resources("libvirt::libvirtd_config", $libvirtd_config)

  # Some minor defaults. These may need to differ per OS in the future.
  libvirt::libvirtd_config { ["auth_unix_ro", "auth_unix_rw"]: value => "none" }
  libvirt::libvirtd_config { "unix_sock_group": value => $group }
  libvirt::libvirtd_config { "unix_sock_rw_perms": value => "0770" }

  ####################
  # qemu.conf Config #
  ####################
  file { "${config_dir}/qemu.d":
    ensure => directory,
    purge => true,
    recurse => true,
    require => Package[$package],
    notify => Exec["create_qemu_conf"],
  }
  file { "${config_dir}/qemu.d/00-header":
    content => "# Managed by puppet\n",
    require => Package[$package],
    notify => Exec["create_qemu_conf"],
  }
  exec { "create_qemu_conf":
    command => "/bin/cat ${config_dir}/qemu.d/* > ${qemu_config_file}",
    refreshonly => true,
    require => [ Package[$package], File["${config_dir}/qemu.d"] ],
  }
  file { $qemu_config_file:
    owner => root,
    group => root,
    mode => "0644",
    require => Package[$package],
  }
  create_resources("libvirt::qemu_config", $qemu_config)

}
