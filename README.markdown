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

Puppet module for deploying the [OpenDaylight Software Defined Networking (SDN) controller](http://www.opendaylight.org/).

## Module Description

Deploys and configrues the [OpenDaylight SDN controller](http://www.opendaylight.org/), including systemd configuration.

Both supported install methods default to the lastest stable OpenDaylight release, which is currently Helium 0.2.2 SR2. 

## Setup

### What `opendaylight` affects

* Installs [OpenDaylight](http://www.opendaylight.org/).
* Installs a [systemd unitfile](https://github.com/dfarrell07/opendaylight-systemd/) for OpenDaylight.
* Starts the `opendaylight` systemd service.
* Creates `odl:odl` user:group if they don't already exist.
* Installs Java, which is required by ODL.

### Beginning with `opendaylight`

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

The `install_method` param, and the associated `tarball_url` and `unitfile_url` params, are intended for use by developers who need to install a custom-built version of OpenDaylight, or for automated build processes that need to consume a tarball build artifact.

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

* `opendaylight`: Main entry point to the module. All ODL knobs should be managed through its params.

#### Private classes

* `opendaylight::params`: Contains default `opendaylight` class param values.
* `opendaylight::config`: Manages ODL config, including Karaf features and REST port.
* `opendaylight::install`: Installs ODL from an RPM or tarball.
* `opendaylight::service`: Starts the OpenDaylight service.

## Limitations

* The target OS must use systemd (Fedora 15+, CentOS 7+).
* Only tested on Fedora 20, 21 and CentOS 7.
* CentOS 7 is currently the most stable OS option.

## Development

See [CONTRIBUTING.md](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTING.md) for details about how to contribute to this OpenDaylight Puppet module.

## Release Notes/Contributors

See the [CHANGELOG](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CHANGELOG) for information about releases and [CONTRIBUTORS](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTORS) file for a list of folks who have contributed.
