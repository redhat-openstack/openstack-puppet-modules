# cassandra: A Puppet Module to Install and manage Cassandra and DataStax Agent.
[![Puppet Forge](http://img.shields.io/puppetforge/v/locp/cassandra.svg)](https://forge.puppetlabs.com/locp/cassandra)
[![Github Tag](https://img.shields.io/github/tag/locp/cassandra.svg)](https://github.com/locp/cassandra)
[![Build Status](https://travis-ci.org/locp/cassandra.png?branch=master)](https://travis-ci.org/locp/cassandra)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with cassandra](#setup)
    * [What cassandra affects](#what-cassandra-affects)
    * [Beginning with cassandra](#beginning-with-cassandra)
    * [Upgrading](#upgrading)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Contributers](#contributers)
7. [External Links](#external-links)

## Overview

This module installs and configures Apache Cassandra.  The installation steps
were taken from the installation documentation prepared by DataStax [1] and
the configuration parameters are the same as those for the Puppet module
developed by msimonin [2].

## Setup

### What cassandra affects

* Installs the Cassandra package (default **dsc21**).
* Configures settings in *${config_path}/cassandra.yaml*.
* Optionally insures that the Cassandra service is enabled and running.
* Optionally installs the Cassandra support tools (e.g. cassandra21-tools).
* Optionally configures a Yum repository to install the Cassandra packages
  from (on RedHat).
* Optionally configures an Apt repository to install the Cassandra packages
  from (on Ubuntu).
* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk).
* Optionally installs the DataStax agent.

### Beginning with cassandra

This most basic example would attempt to install the default Cassandra package
(assuming there is an available repository).  See the *Usage*(#usage) section
for more realistic scenarios.

```puppet
node 'example' {
  include '::cassandra'
}
```

To install the DataStax agent, include the specific class.

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::datastax_agent'
}
```

To install with a reasonably sensible Java environment include the java
subclass.

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::java'
}
```

To install Cassandra with the optional utilities.

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::optutils'
}
```

To install the main cassandra package (which is mandatory) and all the
optional packages, do the following:

```puppet
node 'example' {
  include '::cassandra'
  include '::cassandra::datastax_agent'
  include '::cassandra::java'
  include '::cassandra::optutils'
}
```

By saying the cassandra class/package is mandatory, what is meant is that all
the sub classes have a dependancy on the main class.  So for example one
could not specify the cassandra::java class for a node with the cassandra
class also being included.

### Upgrading

The following changes to the API have taken place.

**Changes in 0.4.0**

* cassandra::datastax_agent_package_ensure has now been replaced with
  cassandra::datastax_agent::package_ensure.
* cassandra::datastax_agent_service_enable has now been replaced with
  cassandra::datastax_agent::service_enable.
* cassandra::datastax_agent_service_ensure has now been replaced with
  cassandra::datastax_agent::service_ensure.
* cassandra::datastax_agent_package_name has now been replaced with
  cassandra::datastax_agent::package_name.
* cassandra::datastax_agent_service_name has now been replaced with
  cassandra::datastax_agent::service_name.

* cassandra::java_package_ensure has now been replaced with
  cassandra::java::ensure.
* cassandra::java_package_name has now been replaced with
  cassandra::java::package_name.

* cassandra::cassandra_opt_package_ensure has now been replaced with
  cassandra::optutils:ensure.
* cassandra::cassandra_opt_package_name has now been replaced with
  cassandra::optutils:package_name.

**Changes in 0.3.0**

* cassandra_opt_package_ensure changed from 'present' to undef.

* The manage_service option has been replaced with service_enable and
  service_ensure.

## Usage

To install Cassandra in a two node cluster called 'Foobar Cluster' where
node1 (192.168.42.1) is the seed and node2 192.168.42.2 is also to be a
member, do something similar to this:

```puppet
include cassandra::java
include cassandra::optutils

node 'node1' {
  class { 'cassandra':
    cluster_name    => 'Foobar Cluster',
    listen_address  => "${::ipaddress}",
    seeds           => "${::ipaddress}",
    manage_dsc_repo => true
  }
}

node 'node2' {
  class { 'cassandra':
    cluster_name    => 'Foobar Cluster',
    listen_address  => "${::ipaddress}",
    seeds           => '192.168.42.1',
    manage_dsc_repo => true
  }
}
```

This would also ensure that the JDK is installed and the optional Cassandra
tools.

### Class: cassandra

#### Parameters

#####`authenticator`
Authentication backend, implementing IAuthenticator; used to identify users
Out of the box, Cassandra provides
org.apache.cassandra.auth.{AllowAllAuthenticator, PasswordAuthenticator}.

* AllowAllAuthenticator performs no checks - set it to disable authentication.
* PasswordAuthenticator relies on username/password pairs to authenticate
  users. It keeps usernames and hashed passwords in system_auth.credentials
  table. Please increase system_auth keyspace replication factor if you use this
  authenticator.

Default: **AllowAllAuthenticator**

#####`authorizer`
Authorization backend, implementing IAuthorizer; used to limit access/provide
permissions Out of the box, Cassandra provides
org.apache.cassandra.auth.{AllowAllAuthorizer, CassandraAuthorizer}.

* AllowAllAuthorizer allows any action to any user - set it to disable
  authorization.
* CassandraAuthorizer stores permissions in system_auth.permissions table.
  Please increase system_auth keyspace replication factor if you use this
  authorizer.

Default: **AllowAllAuthorizer**

#####`auto_snapshot`
Whether or not a snapshot is taken of the data before keyspace truncation
or dropping of column families. The STRONGLY advised default of true 
should be used to provide data safety. If you set this flag to false, you will
lose data on truncation or drop (default **true**).

#####`cassandra_opt_package_ensure`
The status of the package specified in **cassandra_opt_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*cassandra_opt_package_name* is *undef*, this option has no effect (default
**present**).

#####`cassandra_opt_package_name`
If left at the default, this will change to 'cassandra21-tools' on RedHat
or 'cassandra-tools' on Ubuntu.  Alternatively this use can specify the
package name
(default undef).

#####`cassandra_package_ensure`
The status of the package specified in **cassandra_package_name**.  Can be
*present*, *latest* or a specific version number (default **present**).

#####`cassandra_package_name`
The name of the Cassandra package.  Must be installable from a repository
(default **dsc21**).

#####`cassandra_yaml_tmpl`
The path to the Puppet template for the Cassandra configuration file.  This
allows the user to supply their own customized template.  A Cassandra 1.X
compatible template called cassandra1.yaml.erb has been provided by @Spredzy
(default **cassandra/cassandra.yaml.erb**).

#####`client_encryption_enabled`
Enable or disable client/server encryption (default **false**).

#####`client_encryption_keystore`
Keystore for client_encryption (default **conf/.keystore**).

#####`client_encryption_keystore_password`
Keystore password for client encryption (default **cassandra**).

#####`cluster_name`
The name of the cluster. This is mainly used to prevent machines in one logical
cluster from joining another (default **Test Cluster**).

#####`commitlog_directory`
Commit log.  when running on magnetic HDD, this should be a separate spindle
than the data directories (default **/var/lib/cassandra/commitlog**).

#####`concurrent_counter_writes`
For workloads with more data than can fit in memory, Cassandra's bottleneck
will be reads that need to fetch data from disk. "concurrent_reads"
should be set to (16 * number_of_drives) in order to allow the operations to
enqueue low enough in the stack that the OS and drives can reorder them. Same
applies to "concurrent_counter_writes", since counter writes read the current
values before incrementing and writing them back.

On the other hand, since writes are almost never IO bound, the ideal
number of "concurrent_writes" is dependent on the number of cores in
your system; (8 * number_of_cores) is a good rule of thumb (default **32**).

#####`concurrent_reads`
For workloads with more data than can fit in memory, Cassandra's bottleneck
will be reads that need to fetch data from disk. "concurrent_reads"
should be set to (16 * number_of_drives) in order to allow the operations to
enqueue low enough in the stack that the OS and drives can reorder them. Same
applies to "concurrent_counter_writes", since counter writes read the current
values before incrementing and writing them back.

On the other hand, since writes are almost never IO bound, the ideal
number of "concurrent_writes" is dependent on the number of cores in
your system; (8 * number_of_cores) is a good rule of thumb (default **32**).

#####`concurrent_writes`
For workloads with more data than can fit in memory, Cassandra's bottleneck
will be reads that need to fetch data from disk. "concurrent_reads"
should be set to (16 * number_of_drives) in order to allow the operations to
enqueue low enough in the stack that the OS and drives can reorder them. Same
applies to "concurrent_counter_writes", since counter writes read the current
values before incrementing and writing them back.

On the other hand, since writes are almost never IO bound, the ideal
number of "concurrent_writes" is dependent on the number of cores in
your system; (8 * number_of_cores) is a good rule of thumb (default **32**).

#####`config_path`
The path to the cassandra configuration file.  If this is undef, it will be
changed to /etc/cassandra/default.conf on the RedHat family of operating
systems or /etc/cassandra on Ubuntu.  Otherwise the user can specify the
path name
(default **undef**).

#####`data_file_directories`
Directories where Cassandra should store data on disk.  Cassandra
will spread data evenly across them, subject to the granularity of
the configured compaction strategy (default **['/var/lib/cassandra/data']**).

#####`disk_failure_policy`
Policy for data disk failures:

* die: shut down gossip and Thrift and kill the JVM for any fs errors or
  single-sstable errors, so the node can be replaced.
* stop_paranoid: shut down gossip and Thrift even for single-sstable errors.
* stop: shut down gossip and Thrift, leaving the node effectively dead, but
  can still be inspected via JMX.
* best_effort: stop using the failed disk and respond to requests based on
  remaining available sstables.  This means you WILL see obsolete
  data at CL.ONE!
* ignore: ignore fatal errors and let requests fail, as in pre-1.2 Cassandra.

Default: **stop**

#####`endpoint_snitch`
Set this to a class that implements IEndpointSnitch.  The snitch has two
functions:

* it teaches Cassandra enough about your network topology to route
  requests efficiently.
* it allows Cassandra to spread replicas around your cluster to avoid
  correlated failures. It does this by grouping machines into
  "datacenters" and "racks."  Cassandra will do its best not to have
  more than one replica on the same "rack" (which may not actually
  be a physical location).

IF YOU CHANGE THE SNITCH AFTER DATA IS INSERTED INTO THE CLUSTER,
YOU MUST RUN A FULL REPAIR, SINCE THE SNITCH AFFECTS WHERE REPLICAS
ARE PLACED.

Out of the box, Cassandra provides:

* SimpleSnitch: Treats Strategy order as proximity. This can improve cache
  locality when disabling read repair.  Only appropriate for
  single-datacenter deployments.
* GossipingPropertyFileSnitch: This should be your go-to snitch for production
  use.  The rack and datacenter for the local node are defined in
  cassandra-rackdc.properties and propagated to other nodes via
  gossip.  If cassandra-topology.properties exists, it is used as a
  fallback, allowing migration from the PropertyFileSnitch.
* PropertyFileSnitch: Proximity is determined by rack and data center, which are
  explicitly configured in cassandra-topology.properties.
* Ec2Snitch: Appropriate for EC2 deployments in a single Region. Loads Region
  and Availability Zone information from the EC2 API. The Region is
  treated as the datacenter, and the Availability Zone as the rack.
  Only private IPs are used, so this will not work across multiple Regions.
* Ec2MultiRegionSnitch: Uses public IPs as broadcast_address to allow
  cross-region connectivity.  (Thus, you should set seed addresses to the public
  IP as well.) You will need to open the storage_port or
  ssl_storage_port on the public IP firewall.  (For intra-Region
  traffic, Cassandra will switch to the private IP after
  establishing a connection.)
* RackInferringSnitch: Proximity is determined by rack and data center, which
  are assumed to correspond to the 3rd and 2nd octet of each node's IP
  address, respectively.  Unless this happens to match your
  deployment conventions, this is best used as an example of
  writing a custom Snitch class and is provided in that spirit.

You can use a custom Snitch by setting this to the full class name
of the snitch, which will be assumed to be on your classpath.

Default: **SimpleSnitch**

#####`hinted_handoff_enabled`
See http://wiki.apache.org/cassandra/HintedHandoff May either be "true" or
"false" to enable globally, or contain a list of data centers to enable
per-datacenter (e.g. 'DC1,DC2').  Defaults to **'true'**.

#####`incremental_backups`
Set to true to have Cassandra create a hard link to each sstable
flushed or streamed locally in a backups/ subdirectory of the
keyspace data.  Removing these links is the operator's
responsibility (default **false**).

#####`internode_compression`
Controls whether traffic between nodes is compressed. Can be:

* all  - all traffic is compressed
* dc   - traffic between different datacenters is compressed
* none - nothing is compressed.

Default **all**

#####`listen_address`
Address or interface to bind to and tell other Cassandra nodes to connect to
(default **localhost**).

#####`manage_dsc_repo`
If set to true then a repository will be setup so that packages can be
downloaded from the DataStax community edition (default **false**).

#####`native_transport_port`
Port for the CQL native transport to listen for clients on
For security reasons, you should not expose this port to the internet.
Firewall it if needed (default **9042**).

#####`num_tokens`
This defines the number of tokens randomly assigned to this node on the ring
The more tokens, relative to other nodes, the larger the proportion of data
that this node will store. You probably want all nodes to have the same number
of tokens assuming they have equal hardware capability.

#####`partitioner`
The partitioner is responsible for distributing groups of rows (by
partition key) across nodes in the cluster.  You should leave this
alone for new clusters.  The partitioner can NOT be changed without
reloading all data, so when upgrading you should set this to the
same partitioner you were already using.

Besides Murmur3Partitioner, partitioners included for backwards
compatibility include RandomPartitioner, ByteOrderedPartitioner, and
OrderPreservingPartitioner (default
**org.apache.cassandra.dht.Murmur3Partitioner**)

#####`rpc_address`
The address to bind the Thrift RPC service and native transport server to
(default **localhost**).

#####`rpc_port`
Port for Thrift to listen for clients on (default **9160**).

#####`rpc_server_type`
Cassandra provides two out-of-the-box options for the RPC Server:

* One thread per thrift connection. For a very large number of clients,
  memory will be your limiting factor. On a 64 bit JVM, 180KB is the minimum
  stack size per thread, and that will correspond to your use of virtual memory
  (but physical memory may be limited depending on use of stack space).
* Stands for "half synchronous, half asynchronous." All thrift clients
  are handled asynchronously using a small number of threads that does
  not vary with the amount of thrift clients (and thus scales well to many
  clients).  The rpc requests are still synchronous (one thread per active
  request). If hsha is selected then it is essential that rpc_max_threads
  is changed from the default value of unlimited.

The default is sync because on Windows hsha is about 30% slower.  On Linux,
sync/hsha performance is about the same, with hsha of course using less memory.

Alternatively, you can provide your own RPC server by providing the
fully-qualified class name of an o.a.c.t.TServerFactory that can create an
instance of it.

#####`saved_caches_directory`
Default: **/var/lib/cassandra/saved_caches**

#####`seeds`
Addresses of hosts that are deemed contact points.  Cassandra nodes use this
list of hosts to find each other and learn the topology of the ring.  You must
change this if you are running multiple nodes!  Seeds is actually a
comma-delimited list of addresses (default **127.0.0.1**).

#####`server_encryption_internode`
Enable or disable inter-node encryption (default **none**).

#####`server_encryption_keystore`
Default: **conf/.keystore**

#####`server_encryption_keystore_password`
Default: **cassandra**

#####`server_encryption_truststore`
Default: **conf/.truststore**

#####`server_encryption_truststore_password`
Default: **cassandra**

#####`service_enable`
Enable the Cassandra service to start at boot time.  Valid values are true
or false
(default: **true**)

#####`service_ensure`
Ensure the Cassandra service is running.  Valid values are running or stopped
(default: **running**)

#####`service_name`
The name of the service that runs the Cassandra software (default
**cassandra**).

#####`snapshot_before_compaction`
Whether or not to take a snapshot before each compaction.  Be
careful using this option, since Cassandra won't clean up the
snapshots for you.  Mostly useful if you're paranoid when there
is a data format change (default **false**).

#####`start_native_transport`
Whether to start the native transport server.  Please note that the address on
which the native transport is bound is the same as the rpc_address. The port
however is different and specified below (default **true**).

#####`start_rpc`
Whether to start the thrift rpc server (default **true**).

#####`storage_port`
TCP port, for commands and data for security reasons, you should not expose this
port to the internet.  Firewall it if needed (default **7000**).

### Class: cassandra::datastax_agent

####`package_ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

####`package_name`
Is passed to the package reference (default **datastax-agent**).

####`service_ensure`
Is passed to the service reference (default **running**).

####`service_enable`
Is passed to the service reference (default **true**).

####`service_name`
Is passed to the service reference (default **datastax-agent**).

####`stomp_interface`
If the value is changed from the default of *undef* then this is what is
set as the stomp_interface setting in /var/lib/datastax-agent/conf/address.yaml
which connects the agent to an OpsCenter instance
(default **undef**).

### Class: cassandra::java

####`ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

####`package_name`
If the default value of *undef* is left as it is, then a package called
java-1.8.0-openjdk-headless or openjdk-7-jre-headless will be installed
on a Red Hat family or Ubuntu system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node
(default **undef**).

### Class: cassandra::optutils

####`ensure`
Is passed to the package reference.  Valid values are **present** or a version
number
(default **present**).

####`package_name`
If the default value of *undef* is left as it is, then a package called
cassandra21-tools or cassandra-tools will be installed
on a Red Hat family or Ubuntu system respectively.  Alternatively, one
can specify a package that is available in a package repository to the
node
(default **undef**).

## Reference

This module uses the package type to install the Cassandra package, the
optional Cassandra tools, the DataStax agent and Java package.

It optionally uses the service type to enable the cassandra service and/or the
DataStax agent and ensure that they are running.

It also uses the yumrepo type on the RedHat family of operating systems to
(optionally) install the *DataStax Repo for Apache Cassandra*.

On Ubuntu, the apt class is optionally utilised.

## Limitations

This module currently still has somewhat limited functionality.  More
parameters and configuration parameters will be added later.

There is currently no method for this module to manipulate Java options.

Currently the is no configuration or customisation of the DataStax Agent.

Tested on the RedHat family versions 6 and 7, Ubuntu 12.04 and 14.04, Puppet
(CE) 3.7.5 and DSC 2.1.5.

## Contributers

Contributions will be greatfully accepted.  Please go to the project page,
fork the project, make your changes locally and then raise a pull request.
Details on how to do this are available at
https://guides.github.com/activities/contributing-to-open-source.

### Additional Contributers

Yanis Guenane (GitHub [@spredzy](https://github.com/Spredzy)) provided the
Cassandra 1.x compatible template
(see [#11](https://github.com/locp/cassandra/pull/11)).

## External Links

[1] - *Installing DataStax Community on RHEL-based systems*, available at
http://docs.datastax.com/en/cassandra/2.1/cassandra/install/installRHEL_t.html, accessed 25th May 2015.

[2] - *msimonin/cassandra: Puppet module to install Apache Cassandra from
the DataStax distribution. Forked from gini/cassandra*, available at
https://forge.puppetlabs.com/msimonin/cassandra, accessed 17th March 2015.
