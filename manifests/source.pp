# == definition fluentd::source
define fluentd::source (
    $configfile,
    $type,
    $tag          = false,
    $format       = false,
    $time_format  = false,
    $config       = {},
) {

    concat::fragment { "source_${title}":
        target  => "/etc/td-agent/config.d/${configfile}.conf",
        require => Package["${fluentd::package_name}"],
        content => template('fluentd/source.erb'),
    }
}
