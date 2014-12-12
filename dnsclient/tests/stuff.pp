class { 'dnsclient':
  nameservers                 => [ '4.2.2.2',
                                    '4.2.2.1' ],
#  domain                     => '-invalid.tld',
  domain                      => 'valid-domain.tld',
  resolver_config_file_ensure => 'present',
  resolver_config_file_group  => 'wheel',
}
