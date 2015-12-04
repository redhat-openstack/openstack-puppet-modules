# == definition fluentd::configfile
define fluentd::configfile  {
    $source_conf = "/etc/td-agent/config.d/${title}.conf"
    if ! defined(Class['fluentd']) {
        fail('You must include the fluentd base class before using any fluentd defined resources')
    }
    concat{$source_conf:
        owner   => 'td-agent',
        group   => 'td-agent',
        mode    => '0644',
        require => Class['Fluentd::Packages'],
        notify  => Class['Fluentd::Service'],
    }
}

