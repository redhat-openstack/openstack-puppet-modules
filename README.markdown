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

### Karaf Features

To set extra Karaf features to be installed at OpenDaylight start time, pass them in a list to the `extra_features` param. The extra features you pass will typically be driven by the requirements of your ODL install. You'll almost certainly need to pass some.

```
class { 'opendaylight':
  extra_features => ['odl-ovsdb-plugin', 'odl-ovsdb-openstack'],
}
```

OpenDaylight normally installs a default set of Karaf features at boot. They are recommended, so the ODL Puppet mod defaults to installing them. This can be customized by overriding the `default_features` param. You shouldn't normally need to do so.

```
class { 'opendaylight':
  default_features => ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'],
}
```

### Install Method

**Note: The tarball-based install method descrbed here is under active development. Currently, it's not stable and not recommended. See our GitHub Issues for the latest ([#45](https://github.com/dfarrell07/puppet-opendaylight/issues/45), possibly others). As far as we know, RPM-based installs are working fine.**

The `install_method` param, and the associated `tarball_url` and `unitfile_url` params, are intended for use by developers who need to install a custom-built version of OpenDaylight.

It's recommended that most people use the default RPM-based install.

If you do need to install from a tarball, simply pass `tarball` as the value for `install_method` and optionally pass the URL to your tarball via the `tarball_url` param. The default value for `tarball_url` points at OpenDaylight's latest release. The `unitfile_url` param points at the OpenDaylight systemd .service file used by the RPM and should (very likely) not need to be overridden.

```
class { 'opendaylight':
  install_method => 'tarball',
  tarball_url => '<URL to your custom tarball>',
  unitfile_url => '<URL to your custom unitfile>',
}
```

### Ports

To change the port OpenDaylight's northbound listens on for REST API calls, use the `odl_rest_port` param. This was added because OpenStack's Swift project uses a conflicting port.


```
class { 'opendaylight':
  odl_rest_port => '8080',
}
```

## Reference

### Classes

#### Public classes

* `opendaylight`: This is the modules main class. It installs and configures OpenDaylight.

#### Private classes

* `opendaylight::params`: Manages default param values.
* `opendaylight::config`: Manages the Karaf config file via a template.
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
