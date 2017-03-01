# https://collectd.org/wiki/index.php/Plugin:Disk
class collectd::plugin::disk (
  $ensure         = present,
  $disks          = [],
  $ignoreselected = false,
  $interval       = undef,
  $udevnameattr   = undef,
) {

  validate_array($disks)
  validate_bool($ignoreselected)

  collectd::plugin {'disk':
    ensure   => $ensure,
    content  => template('collectd/plugin/disk.conf.erb'),
    interval => $interval,
  }
}
