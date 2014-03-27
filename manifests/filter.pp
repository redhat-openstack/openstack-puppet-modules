# == definition fluentd::filter
define fluentd::filter (
    $type,
    $format,
    $config = [],
) {
    concat::fragment { 'filter':
        target  => "/etc/td-agent/config.d/${::name}.conf",
        require => Class['Fluentd::Packages'],
        content => template('fluentd/filter.erb'),
    }
}
