[![Build Status](https://travis-ci.org/dfarrell07/puppet-opendaylight.svg)](https://travis-ci.org/dfarrell07/puppet-opendaylight) [![Dependency Status](https://gemnasium.com/dfarrell07/puppet-opendaylight.svg)](https://gemnasium.com/dfarrell07/puppet-opendaylight) [![Join the chat at https://gitter.im/dfarrell07/puppet-opendaylight](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dfarrell07/puppet-opendaylight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
#### Table of Contents 
1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with opendaylight](#setup)
    * [What opendaylight affects](#what-opendaylight-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with opendaylight](#beginning-with-opendaylight)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Puppet module for deploying the OpenDaylight Software Defined Networking (SDN) controller.

## Module Description

Stands up the OpenDaylight SDN controller from an RPM, including systemd configuration.

The currently supported OpenDaylight version is Helium SR2 (0.2.2).

## Setup

### What opendaylight affects

* Installs OpenDaylight archive in /opt/ (may change as RPM matures).
* Installs a [systemd unit file](https://github.com/dfarrell07/opendaylight-systemd/) for OpenDaylight.
* Creates `odl:odl` user:group if they don't already exist.

### Beginning with opendaylight

To install and start OpenDaylight, include the `opendaylight` class: `include opendaylight`.

## Usage

The most basic usage, passing no parameters to the OpenDaylight class, will install and start OepnDaylight with a default configuration.

```
class { 'opendaylight':
}
```

To set extra Karaf features to be installed at OpenDaylight start time, pass them in a list to the `extra_features` param.

```
class { 'opendaylight':
  extra_features => ['odl-ovsdb-plugin', 'odl-ovsdb-openstack'],
}
```

A set of default Karaf features will be set to be installed at ODL start automatically. To override them, pass replacement defaults to the `default_features` param.

```
class { 'opendaylight':
  extra_features => ['odl-ovsdb-plugin', 'odl-ovsdb-openstack'],
  default_features => ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'],
}
```

## Reference

### Classes

#### Public classes

* `opendaylight`: This is the modules main class. It installs and configures OpenDaylight.

#### Private classes

* `opendaylight::params`: Manages default param values.
* `opendaylight::config`: Manages the Karaf config file via a template.
* `opendaylight::init`: Does OS validation, builds full features list, sets ordering relationships between other classes.
* `opendaylight::install`: Chooses the correct Yum repo URL based on OS, installs the OpenDaylight Yum repo, installs the OpenDaylight RPM.
* `opendaylight::service`: Configures and starts the OpenDaylight service.

## Limitations

* The target OS must use systemd (Fedora 15+, CentOS 7+).
* Only tested on Fedora 20, 21 and CentOS 7.
* Currently only supports RPM-based installs.

## Development

See [CONTRIBUTING.md](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTING.md) for details about how to contribute to this OpenDaylight Puppet module.

## Release Notes/Contributors

See the [CHANGELOG](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CHANGELOG) for information about releases and [CONTRIBUTORS](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTORS) file for a list of folks who have contributed.
