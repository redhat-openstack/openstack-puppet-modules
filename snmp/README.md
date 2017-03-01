Puppet Net-SNMP Module
======================

master branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-snmp.png?branch=master)](http://travis-ci.org/razorsedge/puppet-snmp)
develop branch: [![Build Status](https://secure.travis-ci.org/razorsedge/puppet-snmp.png?branch=develop)](http://travis-ci.org/razorsedge/puppet-snmp)

Introduction
------------

This module manages the installation of [Net-SNMP](http://www.net-snmp.org/)
client, server, and trap server.  It also can create a SNMPv3 user with
authentication and privacy passwords.

Actions:

* Installs the SNMP client package and configuration.
* Installs the SNMP daemon package, service, and configuration.
* Installs the SNMP trap daemon service and configuration.
* Creates a SNMPv3 user with authentication and encryption paswords.

OS Support:

* RedHat family  - tested on CentOS 5.9, CentOS 6.6, and CentOS 7.0
* SuSE family    - tested on SLES 11 SP1
* Debian family  - tested on Ubuntu 12.04.2 LTS, Debian 6.0.7, and Debian 7.0
* FreeBSD family - tested on FreeBSD 9.2-RELEASE, FreeBSD 10.0-RELEASE

Class documentation is available via puppetdoc.

Examples
--------

To install the SNMP service listening on all IPv4 and IPv6 interfaces:

```puppet
class { 'snmp':
  agentaddress => [ 'udp:161', 'udp6:161' ],
  com2sec      => [ 'notConfigUser 10.20.30.40/32 SeCrEt' ],
  come2sec6    => [ 'notConfiguser fd48:45d7:f49b:cb0f::1/128 SeCrEt' ],
  contact      => 'root@yourdomain.org',
  location     => 'Phoenix, AZ',
}
```

To install the SNMP service and the client:

```puppet
class { 'snmp':
  manage_client => true,
  snmp_config   => [ 'defVersion 2c', 'defCommunity public', ],
}
```

If you just want to install the SNMP client:

```puppet
class { 'snmp::client':
  snmp_config => [ 'mibdirs +/usr/local/share/snmp/mibs', ],
}
```

Only configure and run the snmptrap daemon:

```puppet
class { 'snmp':
  snmptrapdaddr       => [ 'udp:162', ],
  ro_community        => 'SeCrEt',
  service_ensure      => 'stopped',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  trap_handlers       => [
    'default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local',
    'TRAP-TEST-MIB::demo-trap /home/user/traptest.sh demo-trap',
  ],
  trap_forwards       => [ 'default udp:55.55.55.55:162' ],
}
```

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

Notes
-----

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

Issues
------

* Debian will not support the use of non-numeric OIDs.  Something about [rabid
  freedom](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=561578).

TODO
----

* Figure out how to install the RFC-standard MIBS on Debian so that `snmpwalk
  -v 2c -c public localhost system` will function.
* Possibly support USM and VACM?

Deprecation Warning
-------------------

The classes `snmp::server` and `snmp::trapd` will be merged into class `snmp` in
version 3.0.0 of this module.  All of their class parameters will be made
available in the `snmp` class.

The parameter `install_client` will be renamed to `manage_client` in version
4.0.0 of this module.

The parameters `ro_community`, `rw_community`, `ro_network`, and `rw_network`
will be removed in version 4.0.0 of this module.  The snmptrapd parameter name
will become `authcommunity`.

Contributing
------------

Please see DEVELOP.md for contribution information.

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-snmp on GitHub](https://github.com/razorsedge/puppet-snmp)

[razorsedge/snmp on Puppet Forge](http://forge.puppetlabs.com/razorsedge/snmp)

