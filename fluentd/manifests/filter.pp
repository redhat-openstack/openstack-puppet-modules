# == definition fluentd::match
define fluentd::filter (
  $ensure   = present,
  $config   = {
    'type'     => 'grep',
  },
  $priority = 50,
  $pattern,
) {

  if ($config['type'] == 'grep') {
    if !defined(Fluentd::Install_plugin['fluent-plugin-grep']) {
      fluentd::install_plugin{'fluent-plugin-grep':
        plugin_type => 'gem'
      }
    }
  }

  if ((($regexp != '') or ($exclude != '')) and ($input_key == '')) or (($input_key != '') and ($regexp == '') and ($exclude == '')) {
    fail ('regexp, exlude and input_key must be used in conjuction')
  }

  fluentd::configfile { "filter-${name}":
    ensure   => $ensure,
    content  => template( 'fluentd/filter.erb' ),
    priority => $priority,
  }

}
