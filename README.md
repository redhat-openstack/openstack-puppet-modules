# cassandra

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with cassandra](#setup)
    * [What cassandra affects](#what-cassandra-affects)
    * [Beginning with cassandra](#beginning-with-cassandra)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [External Links](#external-links)

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
  from.
* Optionally installs a JRE/JDK package (e.g. java-1.7.0-openjdk).

### Beginning with cassandra

This most basic example would attempt to install the default Cassandra package
(assuming there is an available repository).  See the following section for
more realistic scenarios.

```puppet
node 'example' {
  include '::cassandra'
}
```

## Usage

To install Cassandra in a two node cluster called 'Foobar Cluster' where
node1 (192.168.42.1) is the seed and a second node called node2
192.168.42.2 is also to be a member, do something similar to this:

```puppet
node 'node1' {
  class { 'cassandra':
    cluster_name               => 'Foobar Cluster',
    listen_address             => "${::ipaddress}",
    seeds                      => "${::ipaddress}",
    cassandra_package_name     => 'dsc21',
    cassandra_opt_package_name => 'cassandra21-tools',
    java_package_name          => 'java-1.7.0-openjdk',
    java_package_ensure        => 'latest',
    manage_dsc_repo            => true
  }
}

node 'node2' {
  class { 'cassandra':
    cluster_name               => 'Foobar Cluster',
    listen_address             => "${::ipaddress}",
    seeds                      => '192.168.42.1',
    cassandra_package_name     => 'dsc21',
    cassandra_opt_package_name => 'cassandra21-tools',
    java_package_name          => 'java-1.7.0-openjdk',
    java_package_ensure        => 'latest',
    manage_dsc_repo            => true
  }
}
```

### Class: cassandra

Currently this is the only class within this module.


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
TODO
(default **true**)

#####`cassandra_opt_package_ensure`
The status of the package specified in **cassandra_opt_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*cassandra_opt_package_name* is *undef*, this option has no effect (default
**present**).

#####`cassandra_opt_package_name`
Optionally specify a support package (e.g. cassandra21-tools).  Nothing is
executed if the default value of **undef** is unchanged.

#####`cassandra_package_ensure`
The status of the package specified in **cassandra_package_name**.  Can be
*present*, *latest* or a specific version number (default **present**).

#####`cassandra_package_name`
The name of the Cassandra package.  Must be installable from a repository
(default **dsc21**).

#####`cassandra_yaml_tmpl`
The path to the Puppet template for the Cassandra configuration file.  This
allows the user to supply their own customized template.
(default **cassandra/cassandra.yaml.erb**).

#####`client_encryption_enabled`
TODO
(default **false**)

#####`client_encryption_keystore`
TODO
(default **conf/.keystore**)

#####`client_encryption_keystore_password`
TODO
(default **cassandra**)

#####`cluster_name`
The name of the cluster. This is mainly used to prevent machines in one logical
cluster from joining another (default **Test Cluster**).

#####`commitlog_directory`
TODO
(default **/var/lib/cassandra/commitlog**)

#####`concurrent_counter_writes`
TODO
(default **32**)

#####`concurrent_reads`
TODO
(default **32**)

#####`concurrent_writes`
TODO
(default **32**)

#####`data_file_directories`
TODO
(default **['/var/lib/cassandra/data']**)

#####`disk_failure_policy`
TODO
(default **stop**)

#####`endpoint_snitch`
TODO
(default **SimpleSnitch**)

#####`incremental_backups`
TODO
(default **false**)

#####`internode_compression`
TODO
(default **all**)

#####`native_transport_port`
TODO
(default **9042**)

#####`partitioner`
TODO
(default **org.apache.cassandra.dht.Murmur3Partitioner**)

#####`rpc_address`
TODO
(default **localhost**)

#####`rpc_port`
TODO
(default **9160**)

#####`rpc_server_type`
TODO
(default **sync**)

#####`saved_caches_directory`
TODO
(default **/var/lib/cassandra/saved_caches**)

#####`server_encryption_internode`
TODO
(default **none**)

#####`server_encryption_keystore`
TODO
(default **conf/.keystore**)

#####`server_encryption_keystore_password`
TODO
(default **cassandra**)

#####`server_encryption_truststore`
TODO
(default **conf/.truststore**)

#####`server_encryption_truststore_password`
TODO
(default **cassandra**)

#####`snapshot_before_compaction`
TODO
(default **false**)

#####`start_native_transport`
TODO
(default **true**)

#####`start_rpc`
TODO
(default **true**)

#####`storage_port`
TODO
(default **7000**)

#####`config_path`
The path to the cassandra configuration file (default
**/etc/cassandra/default.conf**).

#####`hinted_handoff_enabled`
See http://wiki.apache.org/cassandra/HintedHandoff May either be "true" or
"false" to enable globally, or contain a list of data centers to enable
per-datacenter (e.g. 'DC1,DC2').  Defaults to **'true'**.

#####`java_package_ensure`
The status of the package specified in **java_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*java_package_name* is *undef*, this option has no effect (default
**present**).

#####`java_package_name`
Optionally specify a JRE/JDK package (e.g. java-1.7.0-openjdk).  Nothing is
executed if the default value of **undef** is unchanged.

#####`listen_address`
Address or interface to bind to and tell other Cassandra nodes to connect to
(default **localhost**).

#####`manage_dsc_repo`
If set to true then a repository will be setup so that packages can be
downloaded from the DataStax community edition (default **false**).

#####`manage_service`
If set to true then the module will ensure the service is enabled and running.
It would also reload/restart the service if the Cassandra configuration was
changed.  It is possible that this might not be the desired behaviour and the
user would prefer to control the service themselves.  If so, set this option
to false (default **true**).

#####`num_tokens`
This defines the number of tokens randomly assigned to this node on the ring
The more tokens, relative to other nodes, the larger the proportion of data
that this node will store. You probably want all nodes to have the same number
of tokens assuming they have equal hardware capability.

#####`seeds`
Addresses of hosts that are deemed contact points.  Cassandra nodes use this list of hosts to find each other and
learn the topology of the ring.  You must change this if you are running multiple nodes!  Seeds is actually a
comma-delimited list of addresses (default **127.0.0.1**).

#####`service_name`
The name of the service that runs the Cassandra software (default
**cassandra**).

## Reference

This module uses the package type to install the Cassandra package and the
optional Cassandra tools and Java package.

It uses the service type to enable the cassandra service and ensure it is
running.

It also uses the yumrepo type on the RedHat family of operating systems to
(optionally) install the *DataStax Repo for Apache Cassandra*.

## Limitations

This module currently has **VERY** basic functionality.  More parameters and configuration parameters will
be added later.

Tested on CentOS 7, Puppet (CE) 3.7.5 and DSC 2.1.5.

## External Links

[1] - *Installing DataStax Community on RHEL-based systems*, available at
http://docs.datastax.com/en/cassandra/2.1/cassandra/install/installRHEL_t.html, accessed 25th May 2015.

[2] - *msimonin/cassandra: Puppet module to install Apache Cassandra from
the DataStax distribution. Forked from gini/cassandra*, available at
https://forge.puppetlabs.com/msimonin/cassandra, acessed 17th March 2015.
