# https://collectd.org/wiki/index.php/Chains
define collectd::plugin::filter::match (
  $chain,
  $rule,
  $plugin,
  $options = undef,
) {
  include collectd::params
  include collectd::plugin::filter

  unless $plugin in $collectd::plugin::filter::plugin_matches {
    fail("Unknown match plugin '${plugin}' provided")
  }

  ensure_resource('collectd::plugin', "match_${plugin}", {'order' => '02'} )

  $fragment_order = "10_${rule}_1_${title}"
  $conf_file = "${collectd::params::plugin_conf_dir}/filter-chain-${chain}.conf"

  concat::fragment{ "${conf_file}_${fragment_order}":
    order   => $fragment_order,
    content => template('collectd/plugin/filter/match.erb'),
    target  => $conf_file,
  }

}
