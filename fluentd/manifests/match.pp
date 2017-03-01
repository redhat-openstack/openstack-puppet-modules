# == definition fluentd::match
define fluentd::match (
  $ensure   = present,
  $config   = {},
  $priority = 50,
  $pattern,
) {
  fluentd::configfile { "match-${name}":
    ensure   => $ensure,
    content  => template( 'fluentd/match.erb' ),
    priority => $priority,
  }
}
