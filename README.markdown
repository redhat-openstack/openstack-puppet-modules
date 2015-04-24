[![Build Status](https://travis-ci.org/dfarrell07/puppet-opendaylight.svg)](https://travis-ci.org/dfarrell07/puppet-opendaylight) [![Dependency Status](https://gemnasium.com/dfarrell07/puppet-opendaylight.svg)](https://gemnasium.com/dfarrell07/puppet-opendaylight) [![Join the chat at https://gitter.im/dfarrell07/puppet-opendaylight](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/dfarrell07/puppet-opendaylight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# OpenDaylight

#### Table of Contents 
1. [Overview](#overview)
1. [Module Description](#module-description)
1. [Setup](#setup)
  * [What `opendaylight` affects](#what-opendaylight-affects)
  * [Beginning with `opendaylight`](#beginning-with-opendaylight)
1. [Usage](#usage)
  * [Karaf Features](#karaf-features)
  * [Install Method](#install-method)
  * [Ports](#ports)
1. [Reference ](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Overview

Puppet module for deploying the [OpenDaylight Software Defined Networking (SDN) controller](http://www.opendaylight.org/).

## Module Description

Installs and configures the [OpenDaylight SDN controller](http://www.opendaylight.org/).

Both supported [install methods](#install-method) default to the latest stable OpenDaylight release, which is currently Helium 0.2.3 SR3.

## Setup

### What `opendaylight` affects

* Installs [OpenDaylight](http://www.opendaylight.org/).
* Installs a [systemd unitfile](https://github.com/dfarrell07/opendaylight-systemd/) for OpenDaylight.
* Starts the `opendaylight` systemd service.
* Creates `odl:odl` user:group if they don't already exist.
* Installs Java, which is required by ODL.

### Beginning with `opendaylight`

Getting started with the OpenDaylight Puppet module is as simple as declaring the `::opendaylight` class.

The [vagrant-opendaylight](https://github.com/dfarrell07/vagrant-opendaylight/) project provides an easy way to experiment with [applying the ODL Puppet module](https://github.com/dfarrell07/vagrant-opendaylight/tree/master/manifests) to CentOS 7, Fedora 20 and Fedora 21 Vagrant boxes.

```
[~/vagrant-opendaylight]$ vagrant status
Current machine states:

cent7_pup_rpm             not created (virtualbox)
cent7_pup_tb              not created (virtualbox)
cent7_rpm                 not created (virtualbox)
f20_pup_rpm               not created (virtualbox)
f20_pup_tb                not created (virtualbox)
f20_rpm                   not created (virtualbox)
f21_pup_rpm               not created (virtualbox)
f21_pup_tb                not created (virtualbox)
f21_rpm                   not created (virtualbox)
```

## Usage

The most basic usage, passing no parameters to the OpenDaylight class, will install and start OpenDaylight with a default configuration.

```puppet
class { 'opendaylight':
}
```

### Karaf Features

To set extra Karaf features to be installed at OpenDaylight start time, pass them in a list to the `extra_features` param. The extra features you pass will typically be driven by the requirements of your ODL install. You'll almost certainly need to pass some.

```puppet
class { 'opendaylight':
  extra_features => ['odl-ovsdb-plugin', 'odl-ovsdb-openstack'],
}
```

OpenDaylight normally installs a default set of Karaf features at boot. They are recommended, so the ODL Puppet mod defaults to installing them. This can be customized by overriding the `default_features` param. You shouldn't normally need to do so.

```puppet
class { 'opendaylight':
  default_features => ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'],
}
```

### Install Method

The `install_method` param, and the associated `tarball_url` and `unitfile_url` params, are intended for use by developers who need to install a custom-built version of OpenDaylight, or for automated build processes that need to consume a tarball build artifact.

It's recommended that most people use the default RPM-based install.

If you do need to install from a tarball, simply pass `tarball` as the value for `install_method` and optionally pass the URL to your tarball via the `tarball_url` param. The default value for `tarball_url` points at OpenDaylight's latest release. The `unitfile_url` param points at the OpenDaylight systemd .service file used by the RPM and should (very likely) not need to be overridden.

```puppet
class { 'opendaylight':
  install_method => 'tarball',
  tarball_url    => '<URL to your custom tarball>',
  unitfile_url   => '<URL to your custom unitfile>',
}
```

### Ports

To change the port OpenDaylight's northbound listens on for REST API calls, use the `odl_rest_port` param. This was added because OpenStack's Swift project uses a conflicting port.


```puppet
class { 'opendaylight':
  odl_rest_port => '8080',
}
```

## Reference

### Classes

#### Public classes

* `::opendaylight`: Main entry point to the module. All ODL knobs should be managed through its params.

#### Private classes

* `opendaylight::params`: Contains default `opendaylight` class param values.
* `opendaylight::config`: Manages ODL config, including Karaf features and REST port.
* `opendaylight::install`: Installs ODL from an RPM or tarball.
* `opendaylight::service`: Starts the OpenDaylight service.

### `::opendaylight`

#### Parameters

##### `default_features`

Sets the Karaf features to install by default. These should not normally need to be overridden.

Default: `['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']`

Valid options: A list of Karaf feature name strings.

##### `extra_features`

Specifies Karaf features to install in addition to the defaults covered by `default_features`.

Default: `[]`

Valid options: A list of Karaf feature name strings.

##### `odl_rest_port `

Sets the port for the ODL northbound REST interface to listen on.

Default: `'8080'`

Valid options: Valid port numbers as strings or integers.

##### `install_method `

Determines the install method to use for OpenDaylight.

Default: `'rpm'`

Valid options: `'tarball'` or `'rpm'`

##### `tarball_url`

Specifies the ODL tarball to use when installing via the tarball install method.

Default: `'https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.3-Helium-SR3/distribution-karaf-0.2.3-Helium-SR3.tar.gz'`

Valid options: A valid URL to an ODL tarball as a string.

##### `unitfile_url`

Specifies the ODL systemd .service file to use when installing via the tarball install method.

It's very unlikely that you'll need to override this.

Default: `'https://github.com/dfarrell07/opendaylight-systemd/archive/master/opendaylight-unitfile.tar.gz'`

Valid options: A valid URL to a valid ODL system .service file in a tarball as a string.

## Limitations

* Only tested on Fedora 20, 21, CentOS 7 and Ubuntu 14.04.
* CentOS 7 is currently the most stable OS option.
* Our [Fedora 21 Beaker tests are failing](https://github.com/dfarrell07/puppet-opendaylight/issues/63), but it seems to be an issue with the Vagrant image, not the Puppet mod.

## Development

See [CONTRIBUTING.markdown](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTING.markdown) for details about how to contribute to the OpenDaylight Puppet module.

## Release Notes/Contributors

See the [CHANGELOG](https://github.com/dfarrell07/puppet-opendaylight/blob/master/CHANGELOG) or our [git tags](https://github.com/dfarrell07/puppet-opendaylight/releases) for information about releases. See our [git commit history](https://github.com/dfarrell07/puppet-opendaylight/commits/master) for contributor information.
