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

* RedHat family  - tested on CentOS 5.9 and CentOS 6.4
* SuSE family    - tested on SLES 11 SP1
* Debian family  - tested on Ubuntu 12.04.2 LTS, Debian 6.0.7, and Debian 7.0
* FreeBSD family - tested on FreeBSD 9.2-RELEASE, FreeBSD 10.0-RELEASE

Class documentation is available via puppetdoc.

Examples
--------

To install the SNMP service:

    class { 'snmp':
      agentaddress => [ 'udp:161', ],
      ro_community => 'notpublic',
      ro_network   => '10.20.30.40/32',
      contact      => 'root@yourdomain.org',
      location     => 'Phoenix, AZ',
    }

To install the SNMP service and the client:

    class { 'snmp':
      manage_client => true,
      snmp_config   => [ 'defVersion 2c', 'defCommunity public', ],
    }

If you just want to install the SNMP client:

    class { 'snmp::client':
      snmp_config => [ 'mibdirs +/usr/local/share/snmp/mibs', ],
    }

Only configure and run the snmptrap daemon:

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

To install a SNMP version 3 user for snmpd:

    snmp::snmpv3_user { 'myuser':
      authpass => '1234auth',
      privpass => '5678priv',
    }
    class { 'snmp':
      snmpd_config => [ 'rouser myuser authPriv' ],
    }

To install a SNMP version 3 user for snmptrapd:

    snmp::snmpv3_user { 'myuser':
      authpass => 'SeCrEt',
      privpass => 'PhRaSe',
      daemon   => 'snmptrapd',
    }

Notes
-----

* Only tested on CentOS 5.9, CentOS 6.4, Ubuntu 12.04.2 LTS, Debian squeeze, and
  Debian wheezy x86_64.
* SNMPv3 user auth is not yet tested on Debian or Suse osfamilies.
* There is a bug on Debian squeeze of net-snmp's status script. If snmptrapd is
  not running the status script returns 'not running' so puppet restarts the
  snmpd service. The following is a workaround: `class { 'snmp':
  service_hasstatus => false, trap_service_hasstatus => false, }`
* For security reasons, the SNMP daemons are configured to listen on the loopback
  interface (127.0.0.1).  Use `agentaddress` and `snmptrapdaddr` to change this
  configuration.

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

The paramter `install_client` will be renamed to `manage_client` in version
4.0.0 of this module.

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

