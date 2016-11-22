# == Class: contrail::qemu
#
# Update qemu settings
#
# === Parameters:
#
# [*qemu_user*]
#   (optional) username for qemu
#
# [*qemu_group*]
#   (optional) group for qemu
#
# [*qemu_clear_emulator_capabilities*]
#   (optional) clear_emulator_capabilities setting for qemu
#
# [*qemu_cgroup_device_acl*]
#   (optional) cgroup_device_acl setting for qemu
#
class contrail::qemu (
  $qemu_user = '"root"',
  $qemu_group = '"root"',
  $qemu_clear_emulator_capabilities = '0',
  $qemu_cgroup_device_acl = '[ "/dev/null", "/dev/full", "/dev/zero", "/dev/random", "/dev/urandom", "/dev/ptmx", "/dev/kvm", "/dev/kqemu", "/dev/rtc", "/dev/hpet", "/dev/net/tun",]',
) {

  $ini_defaults = { 
    'path' => '/etc/libvirt/qemu.conf', 
    notify => Service['libvirtd'],
  }
  $qemuconf = { 
    '' => {
      'user' => $qemu_user,
      'group' => $qemu_group,
      'clear_emulator_capabilities' => $qemu_clear_emulator_capabilities,
      'cgroup_device_acl' => $qemu_cgroup_device_acl,
    }
  }
  create_ini_settings($qemuconf, $ini_defaults)

}
