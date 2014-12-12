class { 'dnsclient':
  resolver_config_file       => '/tmp/resolv.conf',
  resolver_config_file_group => 'wheel',
}
