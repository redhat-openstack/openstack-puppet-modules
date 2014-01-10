# == definition fluentd::filter
define fluentd::filter (
    $type,
    $format,
    $config = [],
) {
    concat::fragment { 'filter':
        target  => "/etc/td-agent/config.d/${::name}.conf",
        require => Package['td-agent'],
        content => template('fluentd/filter.erb'),
    }
}
