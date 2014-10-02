# puppet-nagios-openstack

Nagios Puppet module for monitoring OpenStack Nodes providing predefined hostgroups and services on Red Hat OSes family - Contributors welcome!

The `nagios::client` class, once included on an OpenStack node such as Nova-compute or a 'Controller' host, grabs the OpenStack related services to be monitored.

The `nagios::server` class configures the Nagios server side by adding the Nagios hosts definitions collected using either:
- PuppetDB if it's configured
or
- A built-in definition sharing mechanism

# Examples
## Simple module usage
### Client
```
class {'nagios::client':
  monitored_ip       => '192.168.0.100',
  nagios_server_host => '192.168.0.200',
}
```

### Server
```
class {'nagios::server':
  admin_password       => 'CHANGEME',
  openstack_adm_passwd => 'CHANGEME',
  openstack_controller => '192.168.0.1,
}
```

## Integrated

### Client
```
# Example Monitoring client
class example::monitoring::client (
  $monitoring,
  $monitoring_host,
  $monitoring_interface,
) {
  case $monitoring {
    'nagios': {
      class {'nagios::client':
        monitored_ip       => getvar("ipaddress_${monitoring_interface}"),
        nagios_server_host => $monitoring_host,
      }
    }
  }
}
```

### Server
```
# Example Monitoring Server
class example::server (
  $admin_password,
  $monitoring,
  $monitoring_adm_passwd,
  $controller_admin_host,
) {
  case $monitoring {
    'nagios': {
      class {'nagios::server':
        admin_password       => $monitoring_adm_passwd,
        openstack_adm_passwd => $admin_password,
        openstack_controller => $controller_admin_host,
      }
    }
  }
}
```
