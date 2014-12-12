# Class: fluentd::config()
#
#
class fluentd::config() {
    file { '/etc/td-agent/td-agent.conf' :
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        content => template('fluentd/td-agent.conf.erb'),
        notify  => Class['fluentd::service'],
    }

    file {'/etc/td-agent/config.d':
        ensure  => 'directory',
        owner   => 'td-agent',
        group   => 'td-agent',
        mode    => '0750',
    }
}