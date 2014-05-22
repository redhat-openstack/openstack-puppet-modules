# == Class kafka::config
#
# This class is called from kafka
#
class kafka::config {
  $install_dir = "/usr/local/kafka-${kafka::version}-${kafka::scala_version}"
  $conf_file = "${install_dir}/config/server.properties"

  file { $conf_file:
    owner   => 'kafka',
    group   => 'kafka',
    mode    => '0644',
    alias   => 'kafka-cfg',
    require => File['kafka-app-dir'],
    content => template('kafka/server.properties.erb'),
  }

  #file { '/etc/init/kafka.conf':
  #  content => template('kafka/init/kafka.conf.erb'),
  #  mode    => '0644',
  #  alias   => 'kafka-init',
  #  require => File[$conf_file],
  #}

}
