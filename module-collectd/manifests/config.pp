# private
class collectd::config (
  $config_file            = $collectd::config_file,
  $plugin_conf_dir        = $collectd::plugin_conf_dir,
  $root_group             = $collectd::root_group,
  $recurse                = $collectd::recurse,
  $fqdnlookup             = $collectd::fqdnlookup,
  $collectd_hostname      = $collectd::collectd_hostname,
  $interval               = $collectd::interval,
  $include                = $collectd::include,
  $purge                  = $collectd::purge,
  $purge_config           = $collectd::purge_config,
  $threads                = $collectd::threads,
  $timeout                = $collectd::timeout,
  $typesdb                = $collectd::typesdb,
  $write_queue_limit_high = $collectd::write_queue_limit_high,
  $write_queue_limit_low  = $collectd::write_queue_limit_low,
  $internal_stats         = $collectd::internal_stats,
  $collectd_version       = $collectd::collectd_version,
) {

  $conf_content = $purge_config ? {
    true    => template('collectd/collectd.conf.erb'),
    default => undef,
  }

  file { 'collectd.conf':
    path    => $config_file,
    content => $conf_content,
  }

  if $purge_config != true {
    # former include of conf_d directory
    file_line { 'include_conf_d':
      ensure => absent,
      line   => "Include \"${plugin_conf_dir}/\"",
      path   => $config_file,
    }
    # include (conf_d directory)/*.conf
    file_line { 'include_conf_d_dot_conf':
      ensure => present,
      line   => "Include \"${plugin_conf_dir}/*.conf\"",
      path   => $config_file,
    }
  }

  file { 'collectd.d':
    ensure  => directory,
    path    => $plugin_conf_dir,
    mode    => '0750',
    owner   => 'root',
    group   => $root_group,
    purge   => $purge,
    recurse => $recurse,
  }

}
