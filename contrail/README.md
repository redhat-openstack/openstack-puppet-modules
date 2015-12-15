# Puppet-contrail

[![Build Status](https://travis-ci.org/redhat-cip/puppet-contrail.png?branch=master)](https://travis-ci.org/redhat-cip/puppet-contrail)
[![Puppet Forge](http://img.shields.io/puppetforge/v/eNovance/contrail.svg)](https://forge.puppetlabs.com/eNovance/contrail)
[![License](http://img.shields.io/:license-apache2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)

#### Table of Contents

1. [Overview - What is the puppet-contrail module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with puppet-contrail](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

A [Puppet Module](http://docs.puppetlabs.com/learning/modules1.html#modules) is a collection of related content that can be used to model the configuration of a discrete service.

Module Description
------------------

The puppet-contrail module is a thorough attempt to make Puppet capable of managing the entirety of OpenContrail.  This includes manifests to provision region specific endpoint and database connections. Types are shipped as part of the puppet-contrail module to assist in manipulation of configuration files.

Setup
-----

**What the puppet-contrail module affects**

* puppet-contrail, the Juniper SDN service.

### Installing puppet-contrail

    example% puppet module install enovance/contrail

### Beginning with puppet-contrail

To utilize the puppet-contrail module's functionality you will need to declare multiple resources.  The following is a modified excerpt from the [spinalstack module](https://github.com/stackforge/puppet-openstack-cloud).  This is not an exhaustive list of all the components needed, we recommend you consult and understand the [spinalstack module](https://github.com/stackforge/puppet-openstack-cloud) and the [core openstack](http://docs.openstack.org) documentation.

**Define a puppet-contrail node**

```puppet
class { 'contrail': }
```

Implementation
--------------

### puppet-contrail

Puppet-contrail is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

Limitations
------------

*

Beaker-Rspec
------------

This module has beaker-rspec tests

To run the tests on the default vagrant node:

```shell
bundle install
bundle exec rake acceptance
```

For more information on writing and running beaker-rspec tests visit the documentation:

* https://github.com/puppetlabs/beaker/wiki/How-to-Write-a-Beaker-Test-for-a-Module

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/sbadia/puppet-contrail/graphs/contributors
