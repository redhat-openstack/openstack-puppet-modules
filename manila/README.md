manila
=======

7.1.0 - 2015.2 - Liberty

#### Table of Contents

1. [Overview - What is the manila module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with manila](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Development - Guide for contributing to the module](#development)
6. [Contributors - Those with commits](#contributors)

Overview
--------

The manila module is part of [OpenStack](https://github.com/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects as part of the core software.  The module itself is used to flexibly configure and manage the file system service for OpenStack.

Module Description
------------------

The manila module is a thorough attempt to make Puppet capable of managing the entirety of manila.  This includes manifests to provision such things as keystone endpoints, RPC configurations specific to manila, and database connections.

This module is tested in combination with other modules needed to build and leverage an entire OpenStack software stack.

Setup
-----

**What the manila module affects**

* [Manila](https://wiki.openstack.org/wiki/Manila), the file system service for OpenStack.

### Installing manila

    puppet module install openstack/manila

### Beginning with manila

To utilize the manila module's functionality you will need to declare multiple resources.  [TODO: add example]


Implementation
--------------

### manila

manila is a combination of Puppet manifests and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### manila_config

The `manila_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/manila/manila.conf` file.

```puppet
manila_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `manila.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

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

* https://github.com/openstack/puppet-manila/graphs/contributors
