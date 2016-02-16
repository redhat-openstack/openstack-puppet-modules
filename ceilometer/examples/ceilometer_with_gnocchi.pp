class { '::ceilometer':
  metering_secret => 'secrete',
  rabbit_userid   => 'ceilometer',
  rabbit_password => 'an_even_bigger_secret',
  rabbit_host     => '127.0.0.1',
}
class { '::ceilometer::db::mysql':
  password => 'a_big_secret',
}
class { '::ceilometer::db':
  database_connection => 'mysql://ceilometer:a_big_secret@127.0.0.1/ceilometer?charset=utf8',
}
class { '::ceilometer::keystone::auth':
  password => 'a_big_secret',
}
class { '::ceilometer::client': }
class { '::ceilometer::expirer': }
class { '::ceilometer::agent::central': }
class { '::ceilometer::agent::notification': }
class { '::ceilometer::api':
  enabled               => true,
  keystone_password     => 'a_big_secret',
  keystone_identity_uri => 'http://127.0.0.1:35357/',
  service_name          => 'httpd',
}
include ::apache
class { '::ceilometer::wsgi::apache':
  ssl => false,
}

class { '::ceilometer::collector':
  meter_dispatcher => ['gnocchi'],
}
class { '::ceilometer::dispatcher::gnocchi':
  filter_service_activity   => false,
  filter_project            => true,
  url                       => 'https://gnocchi:8041',
  archive_policy            => 'high',
  resources_definition_file => 'gnocchi.yaml',
}
