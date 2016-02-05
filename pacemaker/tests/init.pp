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
  cluster_members => "clu-host-1 clu-host-2 clu-host-3",
}

### Disable stonith
class {"pacemaker::stonith":
  disable => true,
}

### Add a stonith device
class {"pacemaker::stonith::ipmilan":
  address  => "10.10.10.100",
  username => "admin",
  password => "admin",
}

pacemaker::resource::ip {"ip-192.168.201.59":
  ip_address   => '192.168.201.59',
  nic          => 'eth3',
  cidr_netmask => '',
  post_success_sleep => 0,
  tries           => 1,
  try_sleep       => 1,
}

pacemaker::resource::ip {"ip-192.168.201.58":
  ip_address => '192.168.201.58',
  tries           => 1,
  try_sleep       => 1,
  post_success_sleep => 0,
}

pacemaker::resource::filesystem{ "fs-varlibglanceimages":
  device       => '192.168.200.100:/mnt/glance',
  directory    => '/var/lib/glance/images/',
  fsoptions    => '',
  fstype       => 'nfs',
  clone_params => '',
  op_params    => 'monitor interval=30s',
  post_success_sleep => 0,
  tries           => 1,
  try_sleep       => 1,
}

pacemaker::resource::service {"lb-haproxy":
  service_name    => 'haproxy',
  op_params       => 'monitor start-delay=10s',
  clone_params    => '',
  post_success_sleep => 0,
  tries           => 1,
  try_sleep       => 1,
}

pacemaker::resource::service {"cinder-api":
  service_name    => 'openstack-cinder-api',
  clone_params    => 'interleave=true',
  post_success_sleep => 0,
  tries           => 1,
  try_sleep       => 1,
}

pacemaker::resource::ocf {"neutron-scale":
  ocf_agent_name => 'neutron:NeutronScale',
  clone_params        => 'globally-unique=true clone-max=3 interleave=true',
  post_success_sleep => 0,
  tries           => 1,
  try_sleep       => 1,
}

pcmk_resource { "galera":
  resource_type   => "galera",
  resource_params => 'enable_creation=true wsrep_cluster_address="gcomm://pcmk-c1a1,pcmk-c1a2,pcmk-c1a3"',
  meta_params     => "master-max=3 ordered=true",
  op_params       => 'promote timeout=300s on-fail=block',
  master_params   => '',
  post_success_sleep => 0,
  tries           => 1,
  try_sleep       => 1,
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

### Add properties
pacemaker::property { 'global-bar':
  property   => 'bar',
  value      => 'baz',
  force      => true,
  tries      => 1,
  try_sleep  => 1,
}

pacemaker::property { 'node-foo':
  property   => 'foo',
  value      => 'baz',
  node       => 'cluster1',
  tries      => 1,
  try_sleep  => 1,
}
