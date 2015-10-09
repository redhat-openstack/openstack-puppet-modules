OpenStack Puppet Modules
========================

6.0.0 - 2015.1 - Kilo

[Puppet](http://puppetlabs.com/puppet/puppet-open-source) modules shared between
[Packstack](https://github.com/stackforge/packstack) and [Foreman](http://theforeman.org/).

How to add a new Puppet module
------------------------------

First you have to install [bade](https://github.com/paramite/bade), a utility
for managing Puppet modules using GIT subtrees.

    git clone https://github.com/paramite/bade
    cd bade
    python setup.py develop

Then create a [fork of the OpenStack Puppet Modules repository](https://help.github.com/articles/fork-a-repo/)
and [create a local clone of it](https://help.github.com/articles/fork-a-repo/#step-2-create-a-local-clone-of-your-fork).

    git clone git@github.com:YOUR_USERNAME/openstack-puppet-modules.git
    cd openstack-puppet-modules

Now create a new [branch](http://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging) in your local clone.

    git checkout -b NAME_OF_THE_MODULE

Afterwards add the new Puppet module, `puppet-module-collectd` in this example.

    bade add --upstream https://github.com/pdxcat/puppet-module-collectd.git --hash cf79540be4623eb9da287f6d579ec4a4f4ddc39b --commit

Finally add some more details (e.g. why you want to add this Puppet module)
to the commit message, push the branch and [initiate a pull request](https://help.github.com/articles/using-pull-requests/#initiating-the-pull-request).

### Installing swift

    puppet module install openstack/swift

### Beginning with swift

You much first setup [exported resources](http://docs.puppetlabs.com/puppet/3/reference/lang_exported.html).

To utilize the swift module's functionality you will need to declare multiple resources.  The following is a modified excerpt from the [openstack module](https://github.com/stackforge/puppet-openstack).  This is not an exhaustive list of all the components needed, we recommend you consult and understand the [openstack module](https://github.com/stackforge/puppet-openstack) and the [core openstack](http://docs.openstack.org) documentation.

**Defining a swift storage node**

```puppet
class { 'swift':
  swift_hash_suffix => 'swift_secret',
}

swift::storage::loopback { ['1', '2']:
 require => Class['swift'],
}

class { 'swift::storage::all':
  storage_local_net_ip => $ipaddress_eth0
}

@@ring_object_device { "${ipaddress_eth0}:6000/1":
  region => 1, # optional, defaults to 1
  zone   => 1,
  weight => 1,
}
@@ring_container_device { "${ipaddress_eth0}:6001/1":
  zone   => 1,
  weight => 1,
}
@@ring_account_device { "${ipaddress_eth0}:6002/1":
  zone   => 1,
  weight => 1,
}

@@ring_object_device { "${ipaddress_eth0}:6000/2":
  region => 2,
  zone   => 1,
  weight => 1,
}
@@ring_container_device { "${ipaddress_eth0}:6001/2":
  region => 2,
  zone   => 1,
  weight => 1,
}
@@ring_account_device { "${ipaddress_eth0}:6002/2":
  region => 2,
  zone   => 1,
  weight => 1,
}

Swift::Ringsync<<||>>
```

Usage
-----

### Class: swift

Class that will set up the base packages and the base /etc/swift/swift.conf

```puppet
class { 'swift': swift_hash_suffix => 'shared_secret', }
```

####`swift_hash_suffix`
The shared salt used when hashing ring mappings.

### Class swift::proxy

Class that installs and configures the swift proxy server.

```puppet
class { 'swift::proxy':
  account_autocreate => true,
  proxy_local_net_ip => $ipaddress_eth1,
  port               => '11211',
}
```

####`account_autocreate`
Specifies if the module should manage the automatic creation of the accounts needed for swift.  This should be set to true if tempauth is also being used.

####`proxy_local_net_ip`
This is the ip that the proxy service will bind to when it starts.

####`port`
The port for which the proxy service will bind to when it starts.

### Class: swift::storage

Class that sets up all of the configuration and dependencies for swift storage server instances.

```puppet
class { 'swift::storage': storage_local_net_ip => $ipaddress_eth1, }
```

####`storage_local_net_ip`
This is the ip that the storage service will bind to when it starts.

### Class: swift::ringbuilder

A class that knows how to build swift rings.  Creates the initial ring via exported resources and rebalances the ring if it is updated.

```puppet
class { 'swift::ringbuilder':
  part_power     => '18',
  replicas       => '3',
  min_part_hours => '1',
}
```

####`part_power`
The number of partitions in the swift ring. (specified as the power of 2)

####`replicas`
The number of replicas to store.

####`min_part_hours`
Time before a partition can be moved.

### Define: swift::storage::server

Defined resource type that can be used to create a swift storage server instance.  If you keep the sever names unique it is possibly to create multiple swift servers on a single physical node.

This will configure an rsync server instance and swift storage instance to
manage the all devices in the devices directory.

```puppet
swift::storage::server { '6010':
  type                 => 'object',
  devices              => '/srv/node',
  storage_local_net_ip => '127.0.0.1'
}
```

####`namevar`
The namevar/title for this type will map to the port where the server is hosted.

####`type`
The type of device, e.g. account, object, or container.

####`device`
The directory where the physical storage device will be mounted.

####`storage_local_net_ip`
This is the ip that the storage service will bind to when it starts.

### Define: swift::storage::loopback

This defined resource type was created to test swift by creating a loopback device that can be used a storage device in the absent of a dedicated block device.

It creates a partition of size [`$seek`] at basedir/[`$name`] using dd with [`$byte_size`], formats is to be a xfs filesystem which is then mounted at [`$mnt_base_dir`]/[`$name`].

Then, it creates an instance of defined class for the xfs file system that will eventually lead the mounting of the device using the swift::storage::mount define.

```puppet
swift::storage::loopback { '1':
  base_dir  => '/srv/loopback-device',
  mnt_base_dir => '/srv/node',
  byte_size => '1024',
  seek      => '25000',
}
```

####`base_dir`
The directory where the flat files will be stored that house the file system to be loop back mounted.

####`mnt_base_dir`
The directory where the flat files that store the file system to be loop back mounted are actually mounted at.

####`byte_size`
The byte size that dd uses when it creates the file system.

####`seek`
The size of the file system that will be created.  Defaults to 25000.

### Class: swift::objectexpirer
Class that will set Swift object expirer, for scheduled deletion of objects.

```puppet
class { 'swift::objectexpirer': }
```

It is assumed that the object expirer service will usually be installed in a proxy node. On Red Hat-based distributions, if the class is included in a non-proxy node, the openstack-swift-proxy package will need to be installed.

### Verifying installation

This modules ships with a simple Ruby script that validates whether or not your swift cluster is functional.

The script can be run as:

`ruby $modulepath/swift/files/swift_tester.rb`

Implementation
--------------

### swift

swift is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

Limitations
------------

* No explicit support external NAS devices (i.e. Nexenta and LFS) to offload the ring replication requirements.

Beaker-Rspec
------------

This module has beaker-rspec tests

To run:

``shell
bundle install
bundle exec rspec spec/acceptance
``

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/openstack/puppet-swift/graphs/contributors
