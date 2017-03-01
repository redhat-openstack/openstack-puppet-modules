# This is an example of site.pp to deploy Gnocchi

class { 'gnocchi::keystone::auth':
  admin_address    => '10.0.0.1',
  internal_address => '10.0.0.1',
  public_address   => '10.0.0.1',
  password         => 'verysecrete',
  region           => 'OpenStack'
}

class { 'gnocchi':
  database_connection => 'mysql://gnocchi:secrete@10.0.0.1/gnocchi?charset=utf8',
}

class { 'gnocchi::api':
  bind_host         => '10.0.0.1',
  identity_uri      => 'https://identity.openstack.org:35357',
  keystone_password => 'verysecrete'
}
