# == definition fluentd::configfile
define fluentd::configfile {

    $source_conf = "/etc/td-agent/config.d/${title}.conf"
    concat{$source_conf:
        owner   => 'td-agent',
        group   => 'td-agent',
        mode    => '0644',
        require => Package['td-agent'],
    }
}

