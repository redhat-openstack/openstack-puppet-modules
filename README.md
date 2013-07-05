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

* RedHat family  - tested on CentOS 5.8 and CentOS 6.2
* SuSE family    - presently unsupported (patches welcome)
* Debian family  - initial Debian & Ubuntu suport (patches welcome)
* Solaris family - presently unsupported (patches welcome)

Class documentation is available via puppetdoc.

Examples
--------

To install the SNMP service:

    class { 'snmp':
      ro_community => 'notpublic',
      ro_network   => '10.20.30.40/32',
      contact      => 'root@yourdomain.org',
      location     => 'Phoenix, AZ',
    }

To install the SNMP service and the client:

    class { 'snmp':
      install_client => true,
      snmp_config    => [ 'defVersion 2c', 'defCommunity public', ],
    }

If you just want to install the SNMP client:

    class { 'snmp::client':
      snmp_config => [ 'mibdirs +/usr/local/share/snmp/mibs', ],
    }

Only configure and run the snmptrap daemon:

    class { 'snmp':
      ro_community        => 'SeCrEt',
      service_ensure      => 'stopped',
      trap_service_ensure => 'running',
      trap_handlers       => [
        'traphandle default /usr/bin/perl /usr/bin/traptoemail me@somewhere.com',
        'traphandle TRAP-TEST-MIB::demo-trap /home/user/traptest.sh demo-trap',
      ],
    }

To install a SNMP version 3 user:

    snmp::snmpv3_user { 'myuser':
      authpass => '1234auth',
      privpass => '5678priv',
    }

Notes
-----

* Only tested on CentOS 5.8, CentOS 6.2 x86_64, and Debian squeeze.
* SNMPv3 user auth is not tested on Debian.
* There is a bug on Debian squeeze of net-snmp's status script. If snmptrapd is
  not running the status script returns 'not running' so puppet restarts the
  snmpd service. The following is a workaround: `class { 'snmp':
  service_hasstatus => false, }`

Issues
------

* Debian will not support the use of non-numeric OIDs.  Something about [rabid
  freedom](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=561578).

Deprecation Warning
-------------------

The classes `snmp::server` and `snmp::trapd` will be merged into class `snmp` in
version 3.0.0 of this module.  All of their class parameters will be made
available in the `snmp` class.

License
-------

Please see LICENSE file.

Copyright
---------

Copyright (C) 2012 Mike Arnold <mike@razorsedge.org>

[razorsedge/puppet-snmp on GitHub](https://github.com/razorsedge/puppet-snmp)

[razorsedge/snmp on Puppet Forge](http://forge.puppetlabs.com/razorsedge/snmp)

