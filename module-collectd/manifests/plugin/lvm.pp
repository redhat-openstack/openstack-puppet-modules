# https://collectd.org/wiki/index.php/Plugin:LVM
class collectd::plugin::lvm (
  $ensure           = present,
  $manage_package   = $true,
  $interval         = undef,
) {

  if $::osfamily == 'Redhat' {
    if $manage_package {
      package { 'collectd-lvm':
        ensure => $ensure,
      }
    }
  }

  collectd::plugin {'lvm':
    ensure   => $ensure,
    interval => $interval,
  }
}
