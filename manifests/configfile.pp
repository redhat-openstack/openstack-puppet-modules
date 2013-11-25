define fluentd::configfile {

  $source_conf = "/etc/td-agent/config.d/$title.conf"
  concat{$source_conf:
    owner => root,
    group => root,
    mode  => '0644',
  }
}

