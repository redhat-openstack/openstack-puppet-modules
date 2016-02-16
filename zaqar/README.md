zaqar
=======

#### Table of Contents

1. [Overview - What is the zaqar module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with zaqar](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Contributors - Those with commits](#contributors)

Overview
--------

The zaqar module is a part of [OpenStack](https://github.com/openstack), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects not part of the core software.  The module its self is used to flexibly configure and manage the FIXME service for OpenStack.

Module Description
------------------

The zaqar module is a thorough attempt to make Puppet capable of managing the entirety of zaqar.  This includes manifests to provision region specific endpoint and database connections.  Types are shipped as part of the zaqar module to assist in manipulation of configuration files.

Setup
-----

**What the zaqar module affects**

[Zaqar](https://wiki.openstack.org/wiki/Zaqar), the queue service for OpenStack.

### Installing zaqar
    zaqar is not currently in Puppet Forge, but is anticipated to be added soon.  Once that happens, you'll be able to install zaqar with:
    puppet module install openstack/zaqar

### Beginning with zaqar

Implementation
--------------

### zaqar

zaqar is a combination of Puppet manifest and ruby code to delivery configuration and extra functionality through types and providers.

### Types

#### zaqar_config

The `zaqar_config` provider is a children of the ini_setting provider. It allows one to write an entry in the `/etc/zaqar/zaqar.conf` file.

```puppet
zaqar_config { 'DEFAULT/verbose' :
  value => true,
}
```

This will write `verbose=true` in the `[DEFAULT]` section.

##### name

Section/setting name to manage from `zaqar.conf`

##### value

The value of the setting to be defined.

##### secret

Whether to hide the value from Puppet logs. Defaults to `false`.

##### ensure_absent_val

If value is equal to ensure_absent_val then the resource will behave as if `ensure => absent` was specified. Defaults to `<SERVICE DEFAULT>`

Limitations
------------

* All the zaqar types use the CLI tools and so need to be ran on the zaqar node.

Beaker-Rspec
------------

This module has beaker-rspec tests

To run the tests on the default vagrant node:

```shell
bundle install
bundle exec rake acceptance
```

For more information on writing and running beaker-rspec tests visit the documentation:

* https://github.com/puppetlabs/beaker-rspec/blob/master/README.md

Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/openstack/puppet-zaqar/graphs/contributors
