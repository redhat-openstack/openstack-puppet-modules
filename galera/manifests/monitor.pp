# == Class: galera::monitor
#
# === Parameters:
#
# [*mysql_username*]
#   Username of the service account used for the clustercheck script.
#
# [*mysql_password*]
#   Password of the service account used for the clustercheck script.
#
# [*mysql_host*]
#   Hostname/IP address of mysql server to monitor.
#   Defaults to 127.0.0.1.
#
# [*mysql_port*]
#   Port used by mysql service.
#   Defaults to 3306.
#
# [*monitor_port*]
#   Port used by galera monitor service.
#   Defaults to 9200.
#
# [*monitor_script*]
#   Full path to monitor script.\
#   Defaults to '/usr/bin/clustercheck'.
#
# [*enabled*]
#   Enable/Disable galera monitor xinetd::service.
#   Defaults to true.
#
# [*create_mysql_user*]
#   Whether to create mysql user or not.
#   Defaults to false.
#
# === Actions:
#
# === Requires:
#
# === Sample usage:
#
# class { 'galera::monitor':
#   mysql_username => 'mon_user',
#   mysql_password => 'mon_pass'
# }
#
class galera::monitor (
  $mysql_username    = 'monitor_user',
  $mysql_password    = 'monitor_pass',
  $mysql_host        = '127.0.0.1',
  $mysql_port        = '3306',
  $monitor_port      = '9200',
  $monitor_script    = '/usr/bin/clustercheck',
  $enabled           = true,
  $create_mysql_user = false,
) {

  if $enabled {
    $monitor_disable = 'no'
  } else {
    $monitor_disable = 'yes'
  }

  file { '/etc/sysconfig/clustercheck':
    mode    => '0640',
    content => template('galera/clustercheck.erb'),
    owner   => 'root',
    group   => 'root',
  }

  xinetd::service { 'galera-monitor':
    disable                 => $monitor_disable,
    port                    => $monitor_port,
    server                  => $monitor_script,
    flags                   => 'REUSE',
    per_source              => 'UNLIMITED',
    service_type            => 'UNLISTED',
    log_on_success          => '',
    log_on_success_operator => '=',
    log_on_failure          => 'HOST',
    log_on_failure_operator => '=',
  }

  if $create_mysql_user {
    mysql_user { "${mysql_username}@${mysql_host}":
      ensure        => present,
      password_hash => mysql_password($mysql_password),
      require       => [File['/root/.my.cnf'],Service['galera']],
    }
  }
}
