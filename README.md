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
* Ensures that the Cassandra service is enabled and running.
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

To install Cassandra in a similar way to what is suggested in the DataStax
documentation do something similar to this:

```puppet
node 'example' {
  class { 'cassandra':
    cassandra_package_name     => 'dsc21',
    cassandra_opt_package_name => 'cassandra21-tools',
    java_package_name          => 'java-1.7.0-openjdk',
    java_package_ensure        => 'latest',
    manage_dsc_repo            => true
  }
}
```

### Class: cassandra

Currently this is the only class within this module.  Therefore, it does
everything.

#### Parameters

[*cluster_name*]
The name of the Cassandra cluster that this node is to be part of (default
**undef**).

[*cassandra_package_name*]
The name of the Cassandra package.  Must be installable from a repository
(default **dsc21**).

[*cassandra_package_ensure*]
The status of the package specified in **cassandra_package_name**.  Can be
*present*, *latest* or a specific version number (default **present**).

[*cassandra_opt_package_name*]
Optionally specify a support package (e.g. cassandra21-tools).  Nothing is
executed if the default value of **undef** is unchanged.

[*cassandra_opt_package_ensure*]
The status of the package specified in **cassandra_opt_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*cassandra_opt_package_name* is *undef*, this option has no effect (default
**present**).

[*java_package_name*]
Optionally specify a JRE/JDK package (e.g. java-1.7.0-openjdk).  Nothing is
executed if the default value of **undef** is unchanged.

[*java_package_ensure*]
The status of the package specified in **java_package_name**.  Can be
*present*, *latest* or a specific version number.  If
*java_package_name* is *undef*, this option has no effect (default
**present**).

[*manage_dsc_repo*]
If set to true then a repository will be setup so that packages can be
downloaded from the DataStax community edition (default **false**).

## Reference

This module uses the package type to install the Cassandra package and the
optional Cassandra tools and Java package.

It uses the service type to enable the cassandra service and ensure it is
running.

It also uses the yumrepo type on the RedHat family of operating systems to
(optionally) install the *DataStax Repo for Apache Cassandra*.

## Limitations

Tested on CentOS 7, Puppet (CE) 3.7.5 and DSC 2.1.5.

## External Links

[1] - *Installing DataStax Community on RHEL-based systems*, available at
http://docs.datastax.com/en/cassandra/2.1/cassandra/install/installRHEL_t.html, accessed 25th May 2015.

[2] - *msimonin/cassandra: Puppet module to install Apache Cassandra from
the DataStax distribution. Forked from gini/cassandra*, available at
https://forge.puppetlabs.com/msimonin/cassandra, acessed 17th March 2015.
