define fluentd::plugin(
  $plugin_ensure = $fluentd::plugin_ensure,
  $plugin_source = $fluentd::plugin_source,
) {
  package { $title:
    ensure   => $plugin_ensure,
    source   => $plugin_source,
    provider => tdagent,
    notify   => Class['Fluentd::Service'],
    require  => Class['Fluentd::Install'],
  }
}
