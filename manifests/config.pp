# Class: fluentd::config()
#
#
class fluentd::config() {
    file { '/etc/td-agent/td-agent.conf' :
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        source  => 'puppet:///modules/fluentd/etc/fluentd/td-agent.conf',
        notify  => Class['fluentd::service'],
    }

    file {'/etc/td-agent/config.d':
        ensure  => 'directory',
        owner   => 'td-agent',
        group   => 'td-agent',
        mode    => '0750',
    }
}