#Net-SNMP

[![Build Status](https://secure.travis-ci.org/razorsedge/puppet-snmp.png?branch=master)](http://travis-ci.org/razorsedge/puppet-snmp)

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with this module](#setup)
    * [What this module affects](#what-this-module-affects)
    * [What this module requires](#requirements)
    * [Beginning with this module](#beginning-with-this module)
    * [Upgrading](#upgrading)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Client](#client)
    * [Trap Daemon](#trap-daemon)
    * [SNMPv3 Users](#snmpv3-users)
    * [Access Control](#access-control)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
    * [OS Support](#os-support)
    * [Notes](#notes)
    * [Issues](#issues)
7. [Development - Guide for contributing to the module](#development)

##Overview

This Puppet module manages the installation and configuration of [Net-SNMP](http://www.net-snmp.org/) client, server, and trap server.  It also can create a SNMPv3 user with authentication and privacy passwords.

##Module Description

Simple Network Management Protocol (SNMP) is a widely used protocol for monitoring the health and welfare of network and computer equipment. [Net-SNMP](http://www.net-snmp.org/) implements SNMP v1, SNMP v2c, and SNMP v3 using both IPv4 and IPv6.  This Puppet module manages the installation and configuration of the Net-SNMP client, server, and trap server.  It also can create a SNMPv3 user with authentication and privacy passwords.

Only platforms that have Net-SNMP available are supported.  This module will not work with AIX or Solaris SNMP.

##Setup

###What this module affects

* Installs the Net-SNMP client package and configuration.
* Installs the Net-SNMP daemon package, service, and configuration.
* Installs the Net-SNMP trap daemon service and configuration.
* Creates a SNMPv3 user with authentication and encryption paswords.

###Beginning with this module

This declaration will get you the SNMP daemon listening on the loopback IPv4 and IPv6 addresses with a v1 and v2c read-only community of 'public'.

```puppet
include ::snmp
```

###Upgrading

####Deprecation Warning

The classes `snmp::server` and `snmp::trapd` will be merged into class `snmp` in version 3.0.0 of this module.  All of their class parameters will be made available in the `snmp` class.

The parameter `install_client` will be renamed to `manage_client` in version 4.0.0 of this module.

The parameters `ro_community`, `rw_community`, `ro_network`, and `rw_network` will be removed in version 4.0.0 of this module.  The snmptrapd parameter name will become `authcommunity`.

##Usage

Most interaction with the snmp module can be done through the main snmp class. This means you can simply toggle the parameters in `::snmp` to have most functionality of the module.  Additional fuctionality can be achieved by only utilizing the `::snmp::client` class or the `::snmp::snmpv3_user` define.

To install the SNMP service listening on all IPv4 and IPv6 interfaces:

```puppet
class { 'snmp':
  agentaddress => [ 'udp:161', 'udp6:161' ],
}
```

To change the SNMP community from the default value and limit the netblocks that can use it:

```puppet
class { 'snmp':
  agentaddress => [ 'udp:161', ],
  ro_community => 'myPassword',
  ro_network   => '192.168.0.0/16',
}
```

To set the responsible person and location of the SNMP system:

```puppet
class { 'snmp':
  contact  => 'root@yourdomain.org',
  location => 'Phoenix, Arizona, U.S.A., Earth, Milky Way',
}
```

###Client

If you just want to install the SNMP client:

```puppet
include ::snmp::client
```

To install the SNMP service and the client:

```puppet
class { 'snmp':
  manage_client => true,
}
```

If you want to pass client configuration stanzas to the snmp.conf file:

```puppet
class { 'snmp':
  snmp_config => [
    'defVersion 2c',
    'defCommunity public',
    'mibdirs +/usr/local/share/snmp/mibs',
  ],
}
```

###Trap Daemon

To only configure and run the snmptrap daemon:

```puppet
class { 'snmp':
  service_ensure      => 'stopped',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  snmptrapdaddr       => [ 'udp:162', ],
  trap_handlers       => [
    'default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local', # optional
    'TRAP-TEST-MIB::demo-trap /home/user/traptest.sh demo-trap', # optional
  ],
  trap_forwards       => [ 'default udp:55.55.55.55:162' ], # optional
}
```

###SNMPv3 Users

To install a SNMP version 3 user for snmpd:

```puppet
snmp::snmpv3_user { 'myuser':
  authpass => '1234auth',
  privpass => '5678priv',
}
class { 'snmp':
  snmpd_config => [ 'rouser myuser authPriv' ],
}
```

To install a SNMP version 3 user for snmptrapd:

```puppet
snmp::snmpv3_user { 'myuser':
  authpass => 'SeCrEt',
  privpass => 'PhRaSe',
  daemon   => 'snmptrapd',
}
```

###Access Control

With traditional access control, you can give a simple password and (optional) network restriction:
```puppet
class { 'snmp':
  ro_community => 'myPassword',
  ro_network   => '10.0.0.0/8',
}
```
and it becomes this in snmpd.conf:
```
rocommunity myPassword 10.0.0.0/8
```
This says that any host on network 10.0.0.0/8 can read any SNMP value via SNMP versions 1 and 2c as long as they provide the password 'myPassword'.

With View-based Access Control Model (VACM), you can do this (more complex) configuration instead:
```puppet
class { 'snmp':
  com2sec  => ['mySecName   10.0.0.0/8 myPassword'],
  groups   => ['myGroupName v1         mySecName',
               'myGroupName v2c        mySecName'],
  views    => ['everyThing  included   .'],
  accesses => ['myGroupName ""      any   noauth  exact  everyThing  none   none'],
}
```
where the variables have the following meanings:
* "mySecName": A security name you have selected.
* "myPassword": The community (password) for the security name.
* "myGroupName": A group name to which you assign security names.
* "everyThing": A view name (i.e. a list of MIBs that will be ACLed as a unit).

and it becomes this in snmpd.conf:
```
com2sec mySecName   10.0.0.0/8 myPassword
group   myGroupName v1         mySecName
group   myGroupName v2c        mySecName
view    everyThing  included   .
access  myGroupName ""      any   noauth  exact  everyThing  none   none
```
This also says that any host on network 10.0.0.0/8 can read any SNMP value via SNMP versions 1 and 2c as long as they provide the password 'myPassword'.  But it also gives you the ability to change *any* of those variables.

Reference: [Manpage of snmpd.conf - Access Control](http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAJ)

##Reference

###Classes

* [`snmp`](#class-snmp): Installs the Net-SNMP software.
* [`snmp::client`](#class-snmpclient): Separately installs the Net-SNMP client software. Can be called from `Class['snmp']`.

###Defines

* [`snmp::snmpv3_user`](#define-snmpsnmpv3_user): Creates a SNMPv3 user with authentication and encryption paswords.

###Class: `snmp`

####Parameters

The following parameters are available in the `::snmp` class:

#####`agentaddress`
An array of addresses, on which snmpd will listen for queries.
Default: [ udp:127.0.0.1:161, udp6:[::1]:161 ]

#####`snmptrapdaddr`
An array of addresses, on which snmptrapd will listen to receive incoming SNMP notifications.
Default: [ udp:127.0.0.1:162, udp6:[::1]:162 ]

#####`ro_community`
Read-only (RO) community string for snmptrap daemon.
Default: public

#####`ro_community6`
Read-only (RO) community string for IPv6.
Default: public

#####`rw_community`
Read-write (RW) community string.
Default: none

#####`rw_community6`
Read-write (RW) community string for IPv6.
Default: none

#####`ro_network`
Network that is allowed to RO query the daemon.
Default: 127.0.0.1

#####`ro_network6`
Network that is allowed to RO query the daemon via IPv6.
Default: ::1/128

#####`rw_network`
Network that is allowed to RW query the daemon.
Default: 127.0.0.1

#####`rw_network6`
Network that is allowed to RW query the daemon via IPv6.
Default: ::1/128

#####`contact`
Responsible person for the SNMP system.
Default: Unknown

#####`location`
Location of the SNMP system.
Default: Unknown

#####`sysname`
Name of the system (hostname).
Default: ${::fqdn}

#####`services`
For a host system, a good value is 72 (application + end-to-end layers).
Default: 72

#####`com2sec`
An array of VACM com2sec mappings.  Must provide SECNAME, SOURCE and COMMUNITY.  See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
Default: [ "notConfigUser default public" ]

#####`com2sec6`
An array of VACM com2sec6 mappings.  Must provide SECNAME, SOURCE and COMMUNITY.  See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
Default: [ "notConfigUser default ${ro_community}" ]

#####`groups`
An array of VACM group mappings.  Must provide GROUP, {v1|v2c|usm|tsm|ksm}, SECNAME.  See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
Default: [ 'notConfigGroup v1  notConfigUser', 'notConfigGroup v2c notConfigUser' ]

#####`views`
An array of views that are available to query.  Must provide VNAME, TYPE, OID, and [MASK].  See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
Default: [ 'systemview included .1.3.6.1.2.1.1', 'systemview included .1.3.6.1.2.1.25.1.1' ]

#####`accesses`
An array of access controls that are available to query.  Must provide GROUP, CONTEXT, {any|v1|v2c|usm|tsm|ksm}, LEVEL, PREFX, READ, WRITE, and NOTIFY.  See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL for details.
Default: [ 'notConfigGroup "" any noauth exact systemview none none' ]

#####`dlmod`
Array of dlmod lines to add to the snmpd.conf file.  Must provide NAME and PATH (ex. "cmaX /usr/lib64/libcmaX64.so").  See http://www.net-snmp.org/docs/man/snmpd.conf.html#lbBD for details.
Default: []

#####`snmpd_config`
Safety valve.  Array of lines to add to the snmpd.conf file.  See http://www.net-snmp.org/docs/man/snmpd.conf.html for all options.
Default: []


#####`disable_authorization`
Disable all access control checks. (yes|no)
Default: no

#####`do_not_log_traps`
Disable the logging of notifications altogether. (yes|no)
Default: no

#####`do_not_log_tcpwrappers`
Disable the logging of tcpwrappers messages, e.g. "Connection from UDP: " messages in syslog. (yes|no)
Default: no

#####`trap_handlers`
An array of programs to invoke on receipt of traps.  Must provide OID and PROGRAM (ex. "IF-MIB::linkDown /bin/traps down").  See http://www.net-snmp.org/docs/man/snmptrapd.conf.html#lbAI for details.
Default: []
Affects snmptrapd.conf

#####`trap_forwards`
An array of destinations to send to on receipt of traps.  Must provide OID and DESTINATION (ex. "IF-MIB::linkUp udp:1.2.3.5:162").  See http://www.net-snmp.org/docs/man/snmptrapd.conf.html#lbAI for details.
Default: []
Affects snmptrapd.conf

#####`snmptrapd_config`
Safety valve.  Array of lines to add to the snmptrapd.conf file.  See http://www.net-snmp.org/docs/man/snmptrapd.conf.html for all options.
Default: []
Affects snmptrapd.conf


#####`manage_client`
Whether to install the Net-SNMP client package. (true|false)
Default: false

#####`snmp_config`
Safety valve.  Array of lines to add to the client's global snmp.conf file.  See http://www.net-snmp.org/docs/man/snmp.conf.html for all options.
Default: []
Affects snmp.conf


#####`ensure`
Ensure if present or absent.
Default: present

#####`autoupgrade`
Upgrade package automatically, if there is a newer version.
Default: false

#####`package_name`
Name of the package.  Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific

#####`snmpd_options`
Commandline options passed to snmpd via init script.
Default: auto-set, platform specific

#####`service_ensure`
Ensure if service is running or stopped.
Default: running

#####`service_name`
Name of SNMP service Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific

#####`service_enable`
Start service at boot.
Default: true

#####`service_hasstatus`
Service has status command.
Default: true

#####`service_hasrestart`
Service has restart command.
Default: true

#####`snmptrapd_options`
Commandline options passed to snmptrapd via init script.
Default: auto-set, platform specific

#####`trap_service_ensure`
Ensure if service is running or stopped.
Default: stopped

#####`trap_service_name`
Name of SNMP service Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific

#####`trap_service_enable`
Start service at boot.
Default: true

#####`trap_service_hasstatus`
Service has status command.
Default: true

#####`trap_service_hasrestart`
Service has restart command.
Default: true

#####`openmanage_enable`
Adds the smuxpeer directive to the snmpd.conf file to allow net-snmp to talk with Dell's OpenManage.
Default: false


###Class: `snmp::client`

####Parameters

The following parameters are available in the `::snmp::client` class:

####`snmp_config`
Array of lines to add to the client's global snmp.conf file.  See http://www.net-snmp.org/docs/man/snmp.conf.html for all options.
Default: []

####`ensure`
Ensure if present or absent.
Default: present

####`autoupgrade`
Upgrade package automatically, if there is a newer version.
Default: false

####`package_name`
Name of the package.  Only set this if your platform is not supported or you know what you are doing.
Default: auto-set, platform specific


###Define: `snmp::snmpv3_user`

####Parameters

The following parameters are available in the `::snmp::snmpv3_user` define:

####`title`
Name of the user.
Required

####`authpass`
Authentication password for the user.
Required

####`authtype`
Authentication type for the user.  SHA or MD5
Default: SHA

####`privpass`
Encryption password for the user.
Default: no encryption password

####`privtype`
Encryption type for the user.  AES or DES
Default: AES

####`daemon`
Which daemon file in which to write the user.  snmpd or snmptrapd
Default: snmpd


##Limitations

###OS Support:

Net-SNMP module support is available with these operating systems:

* RedHat family  - tested on CentOS 5.9, CentOS 6.6, and CentOS 7.0
* SuSE family    - tested on SLES 11 SP1
* Debian family  - tested on Ubuntu 12.04.2 LTS, Debian 6.0.7, and Debian 7.0
* FreeBSD family - tested on FreeBSD 9.2-RELEASE, FreeBSD 10.0-RELEASE

###Notes:

* By default the SNMP service now listens on BOTH the IPv4 and IPv6 loopback
  addresses.
* Only tested on CentOS 5.9, CentOS 6.6, CentOS 7.0, Ubuntu 12.04.2 LTS, Debian
  squeeze, and Debian wheezy x86_64.
* SNMPv3 user auth is not yet tested on Debian or Suse osfamilies.
* There is a bug on Debian squeeze of net-snmp's status script. If snmptrapd is
  not running the status script returns 'not running' so puppet restarts the
  snmpd service. The following is a workaround: `class { 'snmp':
  service_hasstatus => false, trap_service_hasstatus => false, }`
* For security reasons, the SNMP daemons are configured to listen on the loopback
  interfaces (127.0.0.1 and [::1]).  Use `agentaddress` and `snmptrapdaddr` to change this
  configuration.
* Not all parts of [Traditional Access
  Control](http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAK) or [VACM
  Configuration](http://www.net-snmp.org/docs/man/snmpd.conf.html#lbAL) are
  fully supported in this module.

###Issues:

* Debian will not support the use of non-numeric OIDs.  Something about [rabid
  freedom](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=561578).
* Figure out how to install the RFC-standard MIBS on Debian so that `snmpwalk
  -v 2c -c public localhost system` will function.
* Possibly support USM and VACM?

##Development

Please see [DEVELOP.md](DEVELOP.md) for information on how to contribute.

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

Licensed under the Apache License, Version 2.0.

[razorsedge/puppet-snmp on GitHub](https://github.com/razorsedge/puppet-snmp)

[razorsedge/snmp on Puppet Forge](https://forge.puppetlabs.com/razorsedge/snmp)

