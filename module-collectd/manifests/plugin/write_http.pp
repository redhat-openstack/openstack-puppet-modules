# https://collectd.org/wiki/index.php/Plugin:Write_HTTP
class collectd::plugin::write_http (
  $ensure     = present,
  $interval   = undef,
  $urls  = {},
) {

  validate_hash($urls)

  if $::osfamily == 'Redhat' {
    package { 'collectd-write_http':
      ensure => $ensure,
    }
  }

  collectd::plugin {'write_http':
    ensure   => $ensure,
    content  => template('collectd/plugin/write_http.conf.erb'),
    interval => $interval,
  }
}
