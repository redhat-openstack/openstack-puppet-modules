# https://collectd.org/wiki/index.php/Plugin:LogFile
class collectd::plugin::logfile (
  $ensure        = present,
  $interval      = undef,
  $log_level     = 'info',
  $log_file      = '/var/log/collectd.log',
  $log_timestamp = true
) {
  collectd::plugin { 'logfile':
    ensure   => $ensure,
    content  => template('collectd/plugin/logfile.conf.erb'),
    interval => $interval,
    # Load logging plugin first
    # https://github.com/pdxcat/puppet-module-collectd/pull/166#issuecomment-50591413
    order    => '05',
  }
}
