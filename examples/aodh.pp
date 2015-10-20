class { '::aodh': }
class { '::aodh::api':
  enabled               => true,
  keystone_password     => 'a_big_secret',
  keystone_identity_uri => 'http://127.0.0.1:35357/',
  service_name          => 'httpd',
}
include ::apache
class { '::aodh::wsgi::apache':
  ssl => false,
}
class { '::aodh::auth':
  auth_password => 'a_big_secret',
}
class { '::aodh::evaluator': }
class { '::aodh::notifier': }
class { '::aodh::client': }
