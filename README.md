# cassandra

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with cassandra](#setup)
    * [What cassandra affects](#what-cassandra-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cassandra](#beginning-with-cassandra)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [References](#references)

## Overview

A one-maybe-two sentence summary of what the module does/what problem it solves.
This is your 30 second elevator pitch for your module. Consider including
OS/Puppet version it works with.

This module installs and configures Apache Cassandra.  The installation steps
were taken from the installation documentation prepared by DataStax [1] and
the configuration parameters are the same as those for the Puppet module
developed by msimonin [2].

## Module Description

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### What cassandra affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with cassandra

To install Cassandra in a similar to what is suggested in the DataStax
documentation do something similar to this:

node 'example' {
  class { 'cassandra':
    cassandra_package_name     => 'dsc21',
    cassandra_opt_package_name => 'cassandra21-tools',
    java_package_name          => 'java-1.7.0-openjdk',
    java_package_ensure        => 'latest',
    manage_dsc_repo            => true
  }
}

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## References

[1] - Installing DataStax Community on RHEL-based systems
http://docs.datastax.com/en/cassandra/2.1/cassandra/install/installRHEL_t.html
