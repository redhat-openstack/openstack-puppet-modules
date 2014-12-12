# This resource sets configuration items within qemu.conf.
#
# == Parameters
#
# [namevar]
#   This is the parameter you wish to change. For example 'vnc_listen'.
# [value]
#   The value you wish to set the parameter to.
#
# == Examples
#
#   libvirt::qemu_config { "vnc_listen":
#     value => "0.0.0.0",
#   }
#
# == Authors
#
# Ken Barber <ken@bob.sh>
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
define libvirt::qemu_config(

  $value

  ) {

  file { "${libvirt::params::libvirt_config_dir}/qemu.d/${name}":
    content => template("${module_name}/qemu.conf.erb"),
    notify => Exec["create_qemu_conf"],
  }

}
