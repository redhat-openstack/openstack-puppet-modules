# puppet-module-rpcbind


[![Build Status](https://api.travis-ci.org/ghoneycutt/puppet-module-rpcbind.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-rpcbind)

Puppet module to manage rpcbind

---

# Compatibility

This module is built for use with Puppet v3 on the following platforms.

 * Debian 6
 * EL 6
 * Suse 10
 * Suse 11
 * Suse 12
 * Ubuntu 12.04 LTS

---

# Parameters

package_ensure
--------------
String value for ensure attribute.

- *Default*: 'installed'

package_name
------------
Package(s) to be installed. Accepts string or array.

- *Default*: 'rpcbind'

service_enable
--------------
Boolean value for enable attribute.

- *Default*: true

service_ensure
--------------
String value for ensure attribute.

- *Default*: 'running'

service_name
------------
String of service name.

- *Default*: based on osfamily
