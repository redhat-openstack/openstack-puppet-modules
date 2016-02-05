[![CI Status][4]][1]
[![Dependency Status][5]][2]
[![Project Chatroom][6]][3]

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
  * [Log Verbosity](#log-verbosity)
  * [Enabling ODL OVSDB L3](#enabling-odl-ovsdb-l3)
1. [Reference ](#reference)
1. [Limitations](#limitations)
1. [Development](#development)
1. [Release Notes/Contributors](#release-notescontributors)

## Overview

Puppet module that installs and configures the [OpenDaylight Software Defined
Networking (SDN) controller][7].

## Module Description

Deploys OpenDaylight to various OSs either via an RPM or directly from the
ODL tarball release artifact.

All OpenDaylight configuration should be handled through the ODL Puppet
module's [params](#parameters). If you need a new knob, [please raise an
Issue][8].

Both supported [install methods](#install-method) default to the latest
stable OpenDaylight release, which is currently [a Beryllium ERP][18].

## Setup

### What `opendaylight` affects

* Installs Java, which is required by ODL.
* Creates `odl:odl` user:group if they don't already exist.
* Installs [OpenDaylight][7].
* Installs a [systemd unitfile][9] or [Upstart config file][10] for
OpenDaylight.
* Manipulates OpenDaylight's configuration files according to the params
passed to the `::opendaylight` class.
* Starts the `opendaylight` systemd or Upstart service.

### Beginning with `opendaylight`

Getting started with the OpenDaylight Puppet module is as simple as declaring
the `::opendaylight` class.

The [vagrant-opendaylight][11] project provides an easy way to experiment
with [applying the ODL Puppet module][12] to CentOS 7, Fedora 22 and Fedora
23 Vagrant boxes.

```
[~/vagrant-opendaylight]$ vagrant status
Current machine states:

cent7                     not created (libvirt)
cent7_rpm_he_sr4          not created (libvirt)
cent7_rpm_li_sr2          not created (libvirt)
cent7_rpm_be              not created (libvirt)
cent7_ansible             not created (libvirt)
cent7_ansible_be          not created (libvirt)
cent7_ansible_path        not created (libvirt)
cent7_pup_rpm             not created (libvirt)
cent7_pup_custom_logs     not created (libvirt)
cent7_pup_tb              not created (libvirt)
f22_rpm_li                not created (libvirt)
f22_ansible               not created (libvirt)
f22_pup_rpm               not created (libvirt)
f23_rpm_li                not created (libvirt)
f23_rpm_li_sr1            not created (libvirt)
f23_rpm_li_sr2            not created (libvirt)
f23_rpm_li_sr3            not created (libvirt)
f23_rpm_be                not created (libvirt)
f23_ansible               not created (libvirt)
f23_pup_rpm               not created (libvirt)

[~/vagrant-opendaylight]$ vagrant up cent7_pup_rpm
# A CentOS 7 VM is created and configured using the ODL Puppet mod's defaults
[~/vagrant-opendaylight]$ vagrant ssh cent7_pup_rpm
[vagrant@localhost ~]$ sudo systemctl is-active opendaylight
active
```

## Usage

The most basic usage, passing no parameters to the OpenDaylight class, will
install and start OpenDaylight with a default configuration.

```puppet
class { 'opendaylight':
}
```

### Karaf Features

To set extra Karaf features to be installed at OpenDaylight start time, pass
them in a list to the `extra_features` param. The extra features you pass will
typically be driven by the requirements of your ODL install. You'll almost
certainly need to pass some.

```puppet
class { 'opendaylight':
  extra_features => ['odl-ovsdb-plugin', 'odl-ovsdb-openstack'],
}
```

OpenDaylight normally installs a default set of Karaf features at boot. They
are recommended, so the ODL Puppet mod defaults to installing them. This can
be customized by overriding the `default_features` param. You shouldn't
normally need to do so.

```puppet
class { 'opendaylight':
  default_features => ['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management'],
}
```

### Install Method

The `install_method` param, and the associated `tarball_url` and `unitfile_url`
params, are intended for use by developers who need to install a custom-built
version of OpenDaylight, or for automated build processes that need to consume
a tarball build artifact.

It's recommended that most people use the default RPM-based install.

If you do need to install from a tarball, simply pass `tarball` as the value
for `install_method` and optionally pass the URL to your tarball via the
`tarball_url` param. The default value for `tarball_url` points at
OpenDaylight's latest release. The `unitfile_url` param points at the
OpenDaylight systemd .service file used by the RPM and should (very likely)
not need to be overridden.

```puppet
class { 'opendaylight':
  install_method => 'tarball',
  tarball_url    => '<URL to your custom tarball>',
  unitfile_url   => '<URL to your custom unitfile>',
}
```

### Ports

To change the port on which OpenDaylight's northbound listens for REST API
calls, use the `odl_rest_port` param.


```puppet
class { 'opendaylight':
  odl_rest_port => '8080',
}
```

### Log Verbosity

It's possible to define custom logger verbosity levels via the `log_levels`
param.

```puppet
class { 'opendaylight':
  log_levels => { 'org.opendaylight.ovsdb' => 'TRACE', 'org.opendaylight.ovsdb.lib' => 'INFO' },
}
```

### Enabling ODL OVSDB L3

To enable the ODL OVSDB L3, use the `enable_l3` flag. It's disabled by default.

```puppet
class { 'opendaylight':
  enable_l3 => true,
}
```

## Reference

### Classes

#### Public classes

* `::opendaylight`: Main entry point to the module. All ODL knobs should be
managed through its params.

#### Private classes

* `::opendaylight::params`: Contains default `opendaylight` class param values.
* `::opendaylight::install`: Installs ODL from an RPM or tarball.
* `::opendaylight::config`: Manages ODL config, including Karaf features and
REST port.
* `::opendaylight::service`: Starts the OpenDaylight service.

### `::opendaylight`

#### Parameters

##### `default_features`

Sets the Karaf features to install by default. These should not normally need
to be overridden.

Default: `['config', 'standard', 'region', 'package', 'kar', 'ssh', 'management']`

Valid options: A list of Karaf feature names as strings.

##### `extra_features`

Specifies Karaf features to install in addition to the defaults listed in
`default_features`.

You will likely need to customize this to your use-case.

Default: `[]`

Valid options: A list of Karaf feature names as strings.

##### `install_method `

Specifies the install method by which to install OpenDaylight.

The RPM install method is less complex, more frequently consumed and
recommended.

Default: `'rpm'`

Valid options: The strings `'tarball'` or `'rpm'`.

##### `odl_rest_port `

Specifies the port for the ODL northbound REST interface to listen on.

Default: `'8080'`

Valid options: A valid port number as a string or integer.

##### `log_levels`

Custom OpenDaylight logger verbosity configuration.

Default: `{}`

Valid options: A hash of loggers to log levels.

```
{ 'org.opendaylight.ovsdb' => 'TRACE', 'org.opendaylight.ovsdb.lib' => 'INFO' }
```

Valid log levels are TRACE, DEBUG, INFO, WARN, and ERROR.

The above example would add the following logging configuration to
`/opt/opendaylight/etc/org.ops4j.pax.logging.cfg`.

```
# Log level config added by puppet-opendaylight
log4j.logger.org.opendaylight.ovsdb = TRACE

# Log level config added by puppet-opendaylight
log4j.logger.org.opendaylight.ovsdb.lib = INFO
```

To view loggers and their verbosity levels, use `log:list` at the ODL Karaf shell.

```
opendaylight-user@root>log:list
Logger                     | Level
----------------------------------
ROOT                       | INFO
org.opendaylight.ovsdb     | TRACE
org.opendaylight.ovsdb.lib | INFO
```

The main log output file is `/opt/opendaylight/data/log/karaf.log`.

##### `enable_l3`

Enable or disable ODL OVSDB L3 forwarding.

Default: `'no'`

Valid options: The strings `'yes'` or `'no'` or boolean values `true` and `false`.

The ODL OVSDB L3 config in `/opt/opendaylight/etc/custom.properties` is set to
the value of the `enable_l3` param.

A manifest like

```puppet
class { 'opendaylight':
  enable_l3 => true,
}
```

Would would result in

```
ovsdb.l3.fwd.enabled=yes
```

##### `tarball_url`

Specifies the ODL tarball to use when installing via the tarball install
method.

Default: `'https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/distribution-karaf/0.3.2-Lithium-SR2/distribution-karaf-0.3.2-Lithium-SR2.tar.gz'`

Valid options: A valid URL to an ODL tarball as a string.

##### `unitfile_url`

Specifies the ODL systemd .service file to use when installing via the tarball
install method.

It's very unlikely that you'll need to override this.

Default: `'https://github.com/dfarrell07/opendaylight-systemd/archive/master/opendaylight-unitfile.tar.gz'`

Valid options: A valid URL to an ODL systemd .service file (archived in a
tarball) as a string.

## Limitations

* Tested on Fedora 22, 23, CentOS 7 and Ubuntu 14.04.
* CentOS 7 is currently the most stable OS option.
* The RPM install method is likely more reliable than the tarball install
method.

## Development

We welcome contributions and work to make them easy!

See [CONTRIBUTING.markdown][14] for details about how to contribute to the
OpenDaylight Puppet module.

## Release Notes/Contributors

See the [CHANGELOG][15] or our [git tags][16] for information about releases.
See our [git commit history][17] for contributor information.


[1]: https://travis-ci.org/dfarrell07/puppet-opendaylight
[2]: https://gemnasium.com/dfarrell07/puppet-opendaylight
[3]: https://gitter.im/dfarrell07/puppet-opendaylight?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge
[4]: https://travis-ci.org/dfarrell07/puppet-opendaylight.svg
[5]: https://gemnasium.com/dfarrell07/puppet-opendaylight.svg
[6]: https://badges.gitter.im/Join%20Chat.svg
[7]: http://www.opendaylight.org/
[8]: https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTING.markdown#issues
[9]: https://github.com/dfarrell07/opendaylight-systemd/
[10]: https://github.com/dfarrell07/puppet-opendaylight/blob/master/files/upstart.odl.conf
[11]: https://github.com/dfarrell07/vagrant-opendaylight/
[12]: https://github.com/dfarrell07/vagrant-opendaylight/tree/master/manifests
[13]: https://github.com/dfarrell07/puppet-opendaylight/issues/63
[14]: https://github.com/dfarrell07/puppet-opendaylight/blob/master/CONTRIBUTING.markdown
[15]: https://github.com/dfarrell07/puppet-opendaylight/blob/master/CHANGELOG
[16]: https://github.com/dfarrell07/puppet-opendaylight/releases
[17]: https://github.com/dfarrell07/puppet-opendaylight/commits/master
[18]: http://cbs.centos.org/repos/nfv7-opendaylight-4-testing/x86_64/os/Packages/
