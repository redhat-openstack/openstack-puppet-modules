case $::osfamily {
  'RedHat': {
    augeas {'httpd-lang' :
      context => '/files/etc/sysconfig/httpd/',
      changes => 'set LANG en_US.UTF-8',
      notify  => Service['httpd'],
      require => Package['httpd'],
    }
  }
  'Debian': {
    # Bug Puppet: https://tickets.puppetlabs.com/browse/PUP-1386
    exec { 'echo \'. /etc/default/locale\' >> /etc/apache2/envvars' :
      path    => ['/bin', '/usr/bin'],
      unless  => 'grep \'^. /etc/default/locale$\' /etc/apache2/envvars',
      notify  => Service['httpd'],
      require => Package['httpd'],
    }
    # Bug Debian: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=736849
    exec { 'echo \'umask 022\' >> /etc/apache2/envvars' :
      path    => ['/bin', '/usr/bin'],
      unless  => 'grep \'umask 022\' /etc/apache2/envvars',
      notify  => Service['httpd'],
      require => Package['httpd'],
    }
  }
  default: {
    fail("Unsupported osfamily (${::osfamily})")
  }
}

class { 'cloud::install::puppetmaster' :
  puppetdb_enable                  => false,
  autosign_domains                 => ['*'],
  agent_configuration              => {
    'agent-ssl_client_header'        => {
      'setting' => 'ssl_client_header',
      'value'   => 'SSL_CLIENT_S_DN'
    },
    'agent-ssl_client_verify_header' => {
      'setting' => 'ssl_client_verify_header',
      'value'   => 'SSL_CLIENT_VERIFY'
    },
    'agent-certname'                 => {
      'setting' => 'certname',
      'value'   => $::fqdn
    },
    'agent-server'                   => {
      'setting' => 'server',
      'value'   => $::fqdn
    },
  },
  main_configuration               => {
    'main-configtimeout' => {
      'setting' => 'configtimeout',
      'value'   => '10m'
    },
  },
  puppetmaster_vhost_configuration => {
    'puppetmasterd' => {
      'docroot'              => '/usr/share/puppet/rack/puppetmasterd/public',
      'port'                 => 8140,
      'ssl'                  => true,
      'ssl_protocol'         => 'ALL -SSLv2 -SSLv3',
      'ssl_cipher'           => 'ALL:!aNULL:!eNULL:!DES:!3DES:!IDEA:!SEED:!DSS:!PSK:!RC4:!MD5:+HIGH:+MEDIUM:!LOW:!SSLv2:!EXP',
      'ssl_honorcipherorder' => 'On',
      'ssl_cert'             => "/var/lib/puppet/ssl/certs/${::fqdn}.pem",
      'ssl_key'              => "/var/lib/puppet/ssl/private_keys/${::fqdn}.pem",
      'ssl_chain'            => '/var/lib/puppet/ssl/certs/ca.pem',
      'ssl_ca'               => '/var/lib/puppet/ssl/certs/ca.pem',
      'ssl_verify_client'    => 'optional',
      'ssl_verify_depth'     => 1,
      'ssl_options'          => ['+StdEnvVars', '+ExportCertData'],
      'request_headers'      => ['unset X-Forwarded-For', 'set X-SSL-Subject %{SSL_CLIENT_S_DN}e', 'set X-Client-DN %{SSL_CLIENT_S_DN}e', 'set X-Client-Verify %{SSL_CLIENT_VERIFY}e'],
      'rack_base_uris'       => '/',
      'add_default_charset'  => 'UTF-8',
    }
  }
}
