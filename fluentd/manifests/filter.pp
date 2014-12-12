# == definition fluentd::filter
define fluentd::filter (
  $configfile,
  $pattern,
  $type               = 'grep',
  $input_key          = '',
  $regexp             = '',
  $exclude            = '',
  $config             = {},
  $output_tag         = '',
  $add_tag_prefix     = '',
  $remove_tag_prefix  = '',
  $add_tag_suffix     = '',
  $remove_tag_suffix  = '',
) {

  if ($type == 'grep') {
    if !defined(Fluentd::Install_plugin['fluent-plugin-grep']) {
      fluentd::install_plugin{'fluent-plugin-grep':
        plugin_type => 'gem'
      }
    }
  }

  if ((($regexp != '') or ($exclude != '')) and ($input_key == '')) or (($input_key != '') and ($regexp == '') and ($exclude == '')) {
    fail ('regexp, exlude and input_key must be used in conjuction')
  }

  concat::fragment { 'filter':
    target  => "/etc/td-agent/config.d/${configfile}.conf",
    require => Class['Fluentd::Packages'],
    content => template('fluentd/filter.erb'),
  }

}
