# Class: fluentd::config()
#
#
class fluentd::config() {
    if $fluentd::product_name == 'fluentd' {
        $config_file = 'fluent'
    } else {
        $config_file = $fluentd::product_name
    }

    file { "/etc/${fluentd::product_name}/${config_file}.conf" :
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        content => template('fluentd/td-agent.conf.erb'),
        notify  => Class['fluentd::service'],
    }

    file {"/etc/${fluentd::product_name}/config.d":
        ensure  => 'directory',
        owner   => "${fluentd::product_name}",
        group   => "${fluentd::product_name}",
        mode    => '0750',
    }
}
