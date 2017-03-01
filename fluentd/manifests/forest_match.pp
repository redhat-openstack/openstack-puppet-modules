# == definition fluentd::forest_match
define fluentd::forest_match (
    $configfile,
    $type,
    $pattern,
    $config   = {},
    $servers  = [],
) {

    concat::fragment { "match_${title}":
        target  => "/etc/${fluentd::product_name}/config.d/${configfile}.conf",
        require => Package["${fluentd::package_name}"],
        content => template('fluentd/forest_match.erb'),
    }
}
