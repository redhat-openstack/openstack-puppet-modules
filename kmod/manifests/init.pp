#
# == Class: kmod
#
# Ensures a couple of mandatory files are present before managing their
# content.
#
#
class kmod {

  file { '/etc/modprobe.d': ensure => directory }

  file { [
      '/etc/modprobe.d/modprobe.conf',
      '/etc/modprobe.d/aliases.conf',
      '/etc/modprobe.d/blacklist.conf',
    ]: ensure => present,
  }
}
