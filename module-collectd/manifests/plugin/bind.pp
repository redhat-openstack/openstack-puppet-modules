# https://collectd.org/wiki/index.php/Plugin:BIND
class collectd::plugin::bind (
  $url,
  $ensure         = present,
  $memorystats    = true,
  $opcodes        = true,
  $parsetime      = false,
  $qtypes         = true,
  $resolverstats  = false,
  $serverstats    = true,
  $zonemaintstats = true,
  $views          = [],
  $interval       = undef,
) {

  validate_bool(
    $memorystats,
    $opcodes,
    $parsetime,
    $qtypes,
    $resolverstats,
    $serverstats,
    $zonemaintstats,
  )
  validate_array($views)

  if $::osfamily == 'Redhat' {
    package { 'collectd-bind':
      ensure => $ensure,
    }
  }

  collectd::plugin {'bind':
    ensure   => $ensure,
    content  => template('collectd/plugin/bind.conf.erb'),
    interval => $interval,
  }
}
