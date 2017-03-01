# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation errors
# and view a log of events) or by fully applying the test in a virtual environment
# (to compare the resulting system state to the desired state).
#
# Learn more about module testing here: http://docs.puppetlabs.com/guides/tests_smoke.html
#
include pacemaker

### Installs Pacemaker and corosync and creates a cluster
### Should be run on all pacemaker nodes
class {"pacemaker::corosync":
    cluster_name => "cluster_name",
    cluster_members => "192.168.122.3 192.168.122.7",
}

### Disable stonith
class {"pacemaker::stonith":
    disable => true,
}

### Add a stonith device
class {"pacemaker::stonith::ipmilan":
    address => "192.168.122.103",
    user => "admin",
    password => "admin",
}

### Add resources
### each of these can generally be added to a single
### node, though running them on multiple nodes
### will net the same result
class {"pacemaker::resource::ip":
    ip_address => "192.168.122.223",
    #ensure => "absent",
    group => 'test-group',
}

class {"pacemaker::resource::lsb":
    name => "httpd",
    #ensure => "absent",
    group => 'test-group',
}

class {"pacemaker::resource::mysql":
    name => "my-mysqld",
    group => 'test-group',
    #ensure => "absent",
    #enable_creation => false,
}

class {"pacemaker::resource::filesystem":
    device => "192.168.122.1:/var/www/html",
    directory => "/mnt",
    fstype => "nfs",
    group => 'test-group',
}

# this must be run on all pacemaker/qpidd nodes
class {'pacemaker::resource::qpid':
      name         => "My_qpidd_resource",
      cluster_name => "qpid_cluster",
}

### Add constraints
pacemaker::constraint::base { "ip-192.168.122.223_with_fs-mnt":
  constraint_type => 'colocation',
  first_resource  => 'ip-192.168.122.223',
  second_resource => 'fs-mnt',
}

pacemaker::constraint::base { "ip-192.168.122.223_before_fs-mnt":
  constraint_type => 'order',
  first_resource  => 'ip-192.168.122.223',
  second_resource => 'fs-mnt',
  first_action    => 'start',
  second_action   => 'start',
}

pacemaker::constraint::base { "ip-192.168.122.223_on_192.168.122.3":
  constraint_type => 'location',
  first_resource  => 'ip-192.168.122.223',
  location        => '192.168.122.3',
  score           => 'INFINITY',
}
