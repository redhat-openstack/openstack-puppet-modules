manila
=======

1.0.0 - 2014.2.0 - Juno

#### Table of Contents

1. [Overview - What is the manila module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with manila](#setup)
4. [Implementation - An under-the-hood peek at what the module is doing](#implementation)
5. [Development - Guide for contributing to the module](#development)
6. [Contributors - Those with commits](#contributors)
7. [Release Notes - Notes on the most recent updates to the module](#release-notes)

Overview
--------

The manila module is part of [Stackforge](https://github.com/stackforge), an effort by the OpenStack infrastructure team to provide continuous integration testing and code review for OpenStack and OpenStack community projects not part of the core software.  The module its self is used to flexibly configure and manage the file system service for OpenStack.

Module Description
------------------

The manila module is a thorough attempt to make Puppet capable of managing the entirety of manila.  This includes manifests to provision such things as keystone endpoints, RPC configurations specific to manila, and database connections.

This module is tested in combination with other modules needed to build and leverage an entire OpenStack software stack.  These modules can be found, all pulled together in the [openstack module](https://github.com/stackfoge/puppet-openstack).

Setup
-----

**What the manila module affects**

* manila, the file system service for OpenStack.

### Installing manila

    manila is not currently in Puppet Forge, but is anticipated to be added soon.  Once that happens, you'll be able to install manila with:
    puppet module install puppetlabs/manila

### Beginning with manila

To utilize the manila module's functionality you will need to declare multiple resources.  [TODO: add example]


Implementation
--------------

### manila

manila is a combination of Puppet manifests and ruby code to delivery configuration and extra functionality through types and providers.


Development
-----------

Developer documentation for the entire puppet-openstack project.

* https://wiki.openstack.org/wiki/Puppet-openstack#Developer_documentation

Contributors
------------

* https://github.com/stackforge/puppet-manila/graphs/contributors

Release Notes
-------------

**1.0.0**

* Initial commit
