# == definition fluentd::match
define fluentd::match (
    $configfile,
    $type,
    $pattern,
    $config   = {},
    $servers  = [],
    $order    = undef,
) {

    concat::fragment { "match_${title}":
        target  => "/etc/td-agent/config.d/${configfile}.conf",
        require => Package["${fluentd::package_name}"],
        content => template('fluentd/match.erb'),
        order   => $order,
    }
}
