puppet-gnocchi
==============

#### Table of Contents

1. [Overview - What is the gnocchi module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with gnocchi](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The gnocchi module is a part of [OpenStack](https://github.com/openstack), an effort by the Openstack infrastructure team to provide continuous integration testing and code review for Openstack and Openstack community projects as part of the core software. The module itself is used to flexibly configure and manage the management service for Openstack.

Module Description
------------------

Setup
-----

**What the gnocchi module affects:**

* gnocchi, the HTTP API to store metrics and index resources for OpenStack
  (OpenStack Datapoint Service).

Implementation
--------------

### gnocchi

gnocchi is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### gnocchi_config

The `gnocchi_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/gnocchi/gnocchi.conf` file.

```puppet
gnocchi_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `gnocchi.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

Limitations
-----------

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

The github [contributor graph](https://github.com/openstack/puppet-gnocchi/graphs/contributors).
