####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with kafka](#setup)
    * [What kafka affects](#what-kafka-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with kafka](#beginning-with-kafka)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The kafka module for managing the installation and configuration of [Apache Kafka](http://kafka.apache.org)

[![Build
Status](https://secure.travis-ci.org/puppet-community/puppet-kafka.png)](https://secure.travis-ci.org/puppet-community/puppet-kafka.png)

##Module Description

The Kafka module for managing the installation and configuration of Apache Kafka: it's brokers, producers and consumers.

##Setup

###What kafka affects

Installs the Kafka package and creates a new service.

###Beginning with Kafka

To successfully install Kafka using this module you need to have Apache Zookeeper already running at localhost:2181. You can specify another Zookeeper host:port configuration using the config hash of the kafka:broker class.

The default configuration installs Kafka 0.8.2.1 binaries with Scala 2.10

```puppet
  class { 'kafka': }
```

If you want a Kafka broker server that connects to zookeeper listenting on port 2181:

```puppet
	class { 'kafka::broker':
	  config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
	} 
```

##Usage

You can specify different Kafka binaries packages versions to install. Please take a look at the different Scala and Kafka versions combinations at the [Apache Kafka Website](http://kafka.apache.org/downloads.html)

### Installing Kafka version 0.8.2.2 with scala 2.10

We first install the binary package with:

```puppet
	class { 'kafka':
		version => '0.8.2.2',
		scala_version => '2.10'
	}
```

Then we set a minimal Kafka broker configuration with:

```puppet
	class { 'kafka::broker':
	  config => { 'broker.id' => '0', 'zookeeper.connect' => 'localhost:2181' }
	} 
```

###Classes and Defined Types

####Class: `kafka`
One of the primary classes of the kafka module. This class will install the kafka binaries

**Parameters within `kafka`:**
#####`version`
The version of kafka that should be installed.
#####`scala_version`
The scala version what kafka was built with.
#####`install_dir`
The directory to install kafka to.
#####`mirror_url`
The url where the kafka is downloaded from.
#####`config`
A hash of the configuration options.
#####`install_java`
Install java if it's not already installed.

####Class: `kafka::broker`
One of the primary classes of the kafka module. This class will install a kafka broker.

**Parameters within `kafka::broker`:**
#####`version`
The version of kafka that should be installed.
#####`scala_version`
The scala version what kafka was built with.
#####`install_dir`
The directory to install kafka to.
#####`mirror_url`
The url where the kafka is downloaded from.
#####`config`
A hash of the configuration options.
#####`install_java`
Install java if it's not already installed.

##Reference

###Classes
####Public Classes
* [`kafka`](#class-kafka-broker): Guides the basic installation of kafka binaries
* [`kafka::broker`](#class-kafka-broker): Guides the basic installation of a kafka broker

####Private Classes
* [`kafka::broker::config`]  Manages all the default configuration of the kafka application
* [`kafka::broker::install`] Manages the installation of the kafka packages
* [`kafka::broker::service`] Manages the kafka server service

##Limitations

This module is tested on the following platforms:

* CentOS 5
* CentOS 6
* Ubuntu 12.04
* Ubuntu 14.04

It is tested with the OSS version of Puppet only.

##Development

###Contributing

Please read CONTRIBUTING.md for full details on contributing to this project.
