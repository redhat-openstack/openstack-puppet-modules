# This is an example of site.pp to deploy Gnocchi

class { '::gnocchi::keystone::auth':
  admin_url    => 'http://10.0.0.1:8041',
  internal_url => 'http://10.0.0.1:8041',
  public_url   => 'http://10.0.0.1:8041',
  password     => 'verysecrete',
  region       => 'OpenStack'
}

class { '::gnocchi':
  database_connection => 'mysql://gnocchi:secrete@10.0.0.1/gnocchi?charset=utf8',
}

class { '::gnocchi::api':
  bind_host         => '10.0.0.1',
  identity_uri      => 'https://identity.openstack.org:35357',
  keystone_password => 'verysecrete'
}

class { '::gnocchi::statsd':
  resource_id         => '07f26121-5777-48ba-8a0b-d70468133dd9',
  user_id             => 'f81e9b1f-9505-4298-bc33-43dfbd9a973b',
  project_id          => '203ef419-e73f-4b8a-a73f-3d599a72b18d',
  archive_policy_name => 'high',
  flush_delay         => '100',
}

include ::gnocchi::client
