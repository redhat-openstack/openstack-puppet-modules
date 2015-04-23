# This is an example of site.pp to deploy Tuskar

class { '::tuskar::client': }

class { '::tuskar::keystone::auth':
  admin_address    => '10.0.0.1',
  internal_address => '10.0.0.1',
  public_address   => '10.0.0.1',
  password         => 'verysecrete',
  region           => 'OpenStack'
}

class { '::tuskar::db::mysql':
  password      => 'dbpass',
  host          => '10.0.0.1',
  allowed_hosts => '10.0.0.1'
}

class { '::tuskar':
  database_connection => 'mysql://tuskar:secrete@10.0.0.1/tuskar?charset=utf8',
}

class { '::tuskar::api':
  bind_host         => '10.0.0.1',
  identity_uri      => 'https://identity.openstack.org:35357',
  keystone_password => 'verysecrete'
}
