# Libvirt parameter class. Not to be used directly.
#
# == OS Support
#
# * Debian 7.0 (wheezy)
# * Ubuntu
#
# == Variables
#
# This is a list of variables that must be set for each operating system.
# 
# [libvirt_package]
#   Package(s) for installing libvirt.
# [libvirt_version]
#   Version for libvirt package.
# [libvirt_service]
#   Service for libvirt.
# [libvirt_user]
#   User for libvirt. This is for process and for socket permissions.
# [libvirt_group]
#   Group for libvirt. This is for process and for socket permissions.
# [libvirt_config_dir]
#   Path to configuration directory for libvirt.
# [libvirtd_config_file]
#   Path to libvirtd.conf.
# [qemu_config_file]
#   Path to qemu.conf.
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class libvirt::params {

  case $operatingsystem {
    'ubuntu', 'debian': {
      $libvirt_package = "libvirt-bin"
      $libvirt_version = "installed"
      $libvirt_service = "libvirt-bin"
      $libvirt_user = "libvirt"
      $libvirt_group = "libvirt"
      $libvirt_config_dir = "/etc/libvirt"
      $libvirtd_config_file = "${libvirt_config_dir}/libvirtd.conf"
      $qemu_config_file = "${libvirt_config_dir}/qemu.conf"
    }
    default: {
      fail("Operating system ${operatingsystem} is not supported")
    }
  }

}
