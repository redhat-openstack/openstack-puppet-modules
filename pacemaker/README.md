# Pacemaker module for puppet

This module manages pacemaker on Linux distros with the pcs tool.

## License
Apache 2.0

## Support & Contact
Please log tickets and issues at https://github.com/radez/puppet-pacemaker

## Description

This module uses the fact osfamily which is supported by Facter 1.6.1+. If you do not have facter 1.6.1 in your environment, the following manifests will provide the same functionality in site.pp (before declaring any node):

    if ! $::osfamily {
      case $::operatingsystem {
        'RedHat', 'Fedora', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL': {
          $osfamily = 'RedHat'
        }
        'ubuntu', 'debian': {
          $osfamily = 'Debian'
        }
        'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
          $osfamily = 'Suse'
        }
        'Solaris', 'Nexenta': {
          $osfamily = 'Solaris'
        }
        default: {
          $osfamily = $::operatingsystem
        }
      }
    }

This module is based on work by Dan Radez

## Usage

### pacemaker
Installs Pacemaker and corosync and creates a cluster

    class {"pacemaker::corosync":
        cluster_name => "cluster_name",
        cluster_members => "clu-host-1 clu-host-2 clu-host-3",
    }

The pacemaker::corosync resource must be executed on each node

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

### Constraints

    pacemaker::constraint::base{ "$name":
                                  constraint_type => (order|location|colocation),
                                  first_resource  => $first_resource,
                                  second_resource => $second_resource,
                                  first_action    => $first_action,
                                  second_action   => $second_action,
                                  location        => $location,
                                  score           => $score,
                                  ensure          => $ensure}
  }


### Resources

A few different types are provided for several pacemaker resource
types.  Howerver, all of these types end up wrapping the pcmk_resource
provider.  The pcmk_resource provider itself essentially wraps the
"pcs resource" command.  Params such as "resource_params,"
"group_params" and "clone_params" map transparently to the command
line for pcs.  I.e., if $clone_params is set to "interleave=true", the
pcs command to create the resource looks like:

    pcs resource create <res_name> <res_type> ... --clone interleave=true

If $clone_params is undef, --clone is omitted from the "pcs resource
create command".  Likewise for $group_params and $master_params.  Use
empty strings for parameters where --clone or --master is
desired on the command line without extra parameters.

$meta_params and $op_params behave somewhat similarly, but without the
distinction between empty strings and undef.  I.e., either "meta
<my-meta-params>" should be present in the pcs resource create command
or not at all.

Finally, $resource_params are simply params that show up as options in
the command immediately after the resource type without any additional
keywords.

#### See the pcs man page

See the pcs man page for documentation for about the "pcs resource
create" subcommand and clone, group, meta, op options, etc.  Note that
older verions of pcs may not be compatible with recent ones in terms
of where arguments and options are expected.

#### Limitation

The pcmk_resource provider (and all pacmaker::resource:: types) will
not update an already existing resource.  I.e., if the resource
myservice already exists without $clone_params, declaring
"pcmk_resource {'myservice': ..." with $clone_params will have no
effect.  The resource would have to be deleted first (either manually
on the command line with "pcs resource delete" or via puppet with
ensure => 'absent') -- then the declaration to create 'myservice' with
$clone_params succeeds as expected.

#### Examples

    ## Note that pacemaker::resource::service results in a systemd:
    ## resource being created if systemd is supported on the OS.
    ## Otherwise it's an lsb: resource.  These examples assume the OS
    ## supports systemd.

    pacemaker::resource::ip {"ip-192.168.201.59":
      ip_address   => '192.168.201.59',
      nic          => 'eth3',
      cidr_netmask => '',
      post_success_sleep => 0,
      tries           => 1,
      try_sleep       => 1,
    }
    #results in Debug: /usr/sbin/pcs resource create ip-192.168.201.59 IPaddr2 ip=192.168.201.59 nic=eth3
    
    # another IP
    pacemaker::resource::ip {"ip-192.168.201.58":
      ip_address => '192.168.201.58',
      tries           => 1,
      try_sleep       => 1,
      post_success_sleep => 0,
    }
    #results in Debug: /usr/sbin/pcs resource create ip-192.168.201.58 IPaddr2 ip=192.168.201.58 cidr_netmask=32

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
    # results in Debug: /usr/sbin/pcs resource create fs-varlibglanceimages Filesystem device=192.168.200.100:/mnt/glance directory=/var/lib/glance/images/ fstype=nfs op monitor interval=30s --clone
    
    pacemaker::resource::service {"lb-haproxy":
      service_name    => 'haproxy',
      op_params       => 'monitor start-delay=10s',
      clone_params    => '',
      post_success_sleep => 0,
      tries           => 1,
      try_sleep       => 1,
    }
    # results in Debug: /usr/sbin/pcs resource create lb-haproxy systemd:haproxy op monitor start-delay=10s --clone

    pacemaker::resource::service {"cinder-api":
      service_name    => 'openstack-cinder-api',
      clone_params    => 'interleave=true',
      post_success_sleep => 0,
      tries           => 1,
      try_sleep       => 1,
    }
    # results in Debug: /usr/sbin/pcs resource create cinder-api systemd:openstack-cinder-api --clone interleave=true
    
    pacemaker::resource::ocf {"neutron-scale":
      ocf_agent_name => 'neutron:NeutronScale',
      clone_params        => 'globally-unique=true clone-max=3 interleave=true',
      post_success_sleep => 0,
      tries           => 1,
      try_sleep       => 1,
    }
    # results in Debug: /usr/sbin/pcs resource create neutron-scale ocf:neutron:NeutronScale --clone globally-unique=true clone-max=3 interleave=true
    
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
    # Debug results in : /usr/sbin/pcs resource create galera galera enable_creation=true wsrep_cluster_address="gcomm://pcmk-c1a1,pcmk-c1a2,pcmk-c1a3" meta master-max=3 ordered=true op promote timeout=300s on-fail=block --master

