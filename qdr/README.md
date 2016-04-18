# qdr

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - Manage the QPID Dispatch Router](#module-description)
3. [Setup - The basics of getting started with qdr](#setup)
    * [What qdr affects](#what-qdr-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with qdr](#beginning-with-qdr)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module manages the QPID Dispatch Router (qdr) found at:

     http://qpid.apache.org/components/dispatch-router/

The dispatch router provides flexible and scalable interconnect between any AMQP 1.0 endpoints, whether they be clients, brokers or other AMQP-enabled services

Support is intended for Red Hat and Ubuntu OS family deployed with Pupppet V4.x

## Module Description

This module sets up the installations, configuration and management of the QPID Dispatch
Router (qdr) class and has a number of providers that correpsond the router configuration
entities such as listeners and connectors.

This module will facilitate the deployment of a full/partial mesh topology of QPID Dispatch
Routers serving as the messaging interconnect for a site.


## Setup

### What qdr affects

* repository files
* packages
* configuration files
* service
* configuration entities 

### Beginning with qdr

```puppet
include '::qdr'
```

The default configuration currently installs Qpid-Dispatch-Router 0.5  

## Usage

All configuration parameters can be managed via the main qdr class.

```puppet
class { '::qdr' :
  service_enable            => true,
  container_workder_threads => 4,
  listener_port             => 15672,
}
```

## Class Reference

* qdr: Provides the basic installation and configuration sequence
* qdr::config: Provides qdrouterd configuration 
* qdr::install: Performs package installations
* qdr::params: Aggregates configuration data for router
* qdr::service: Manages the qdrouterd service state


## Resource Types

### qdr\_connector

Resource configuration entity to establish outgoing connections from the router.

Query all current connectors: '$puppet resource qdr_connector'

```puppet
qdr_connector { 'anyConnector' :
  addr           => '10.10.10.10',
  port           => '1234',
  role           => 'inter_router',
  max_frame_size => '65536',
}
```

### qdr\_listener

Listens for incoming connection requests to the router

Query all current listeners: '$puppet resource qdr_listener'

```puppet
qdr_listener { 'anyListener' :
  addr            => '10.10.10.10',
  port            => '5678',
  role            => 'normal',
  sasl_mechanisms => 'DIGEST-MD5,EXTERNAL',
}
```

### qdr\_log

Control log settings for a particular module on the running router

Query all current log module settings: '$puppet resource qdr_log'

### qdr\_user

Users for internal sasl authentication 

Query all current internal users: '$puppet resource qdr_user'

```puppet
qdr_user { 'anyUser' :
  file     => '/var/lib/qdrouterd/qdrouterd.sasldb',
  password => 'changeme',
}
```

## Resource Providers

### qdmanage 

An AMQP management client tool for used with any standard AMQP managed endpoint.

## Limitations

This module has been tested on the following platforms:

* CentOS 7
* Ubuntu 15.10


### Apt module dependence

If running Debian os family, puppetlabs-apt module is required

## Development


## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
