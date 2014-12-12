# ghoneycutt/types
===

Puppet module to manage default types through hashes in Hiera with the
create_resources() function. This module adds validation and helper functions,
such as ensuring directories. Without specifying any hashes, this module will take no action.

You can add any of the supported options for the types in this module. Please see the Puppet Labs [Type Reference](http://docs.puppetlabs.com/references/stable/type.html) for more information.

[![Build Status](https://api.travis-ci.org/ghoneycutt/puppet-module-types.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-types)

===

# Compatibility

This module supports Puppet v3 and Ruby versions 1.8.7, 1.9.3, and 2.0.0.

===

# Parameters

crons
-----
Hash of resource type `cron`.

- *Default*: undef

crons_hiera_merge
-----------------
Boolean to control merges of all found instances of types::crons in Hiera. This is useful for specifying cron resources at different levels of the hierarchy and having them all included in the catalog.

This will default to 'true' in future versions.

- *Default*: false

files
-----
Hash of resource type `file`.

- *Default*: undef

files_hiera_merge
-----------------
Boolean to control merges of all found instances of types::files in Hiera. This is useful for specifying file resources at different levels of the hierarchy and having them all included in the catalog.

This will default to 'true' in future versions.

- *Default*: false

mounts
------
Hash of resource type `mount`.

- *Default*: undef

mounts_hiera_merge
------------------
Boolean to control merges of all found instances of types::mounts in Hiera. This is useful for specifying mount resources at different levels of the hierarchy and having them all included in the catalog.

This will default to 'true' in future versions.

- *Default*: false

services
------
Hash of resource type `service`.

- *Default*: undef

services_hiera_merge
--------------------
Boolean to control merges of all found instances of types::services in Hiera. This is useful for specifying file resources at different levels of the hierarchy and having them all included in the catalog.

- *Default*: true

===

# Defines

## `types::cron`
No helper resources are implemented. Simply passes attributes to a cron resource.

### Parameters required or with defaults

command
-------
The command to execute in the cron job.

- *Required*

ensure
------
State of cron resource. Valid values are 'present' and 'absent'.

- *Default*: 'present'

## `types::file`
No helper resources are implemented. Simply passes attributes to a file resource. The path attribute is not used, so the title must be the fully qualified path.

### Parameters required or with defaults

ensure
------
Whether the file should exist, and if so what kind of file it should be. Possible values are 'present', 'absent', 'file', 'directory', and 'link'.

- *Default*: 'present'

owner
-----
The user to whom the file should belong.

- *Default*: 'root'

group
-----
Which group should own the file.

- *Default*: 'root'

mode
----
Four digit mode.

- *Default*: '0644'

## `types::mount`

Besides ensuring the mount resource, will also ensure that the directory for
the mount exists.

If `options` parameter is passed and it is set to 'defaults' on osfamily
Solaris, it will use '-' as the mount option instead of 'defaults', as
'defaults' is not supported on Solaris.

### Parameters required or with defaults

device
------

- *Required*

fstype
------
Mount type.

- *Required*

ensure
------
State of mount.

- *Default*: mounted

atboot
------
Boolean to mount at boot.

- *Default*: true

### Optional parameters. See type reference for more information.

`blockdevice`, `dump`, `options`, `pass`, `provider`, `remounts`, `target`

## `types::service`
No helper resources are implemented. Simply passes attributes to a service resource.

### mostly used parameters

ensure
------
Whether a service should be running.

Valid values are 'stopped', 'false', 'running' and 'true'.

- *Default*: 'running'

enable
------
Whether a service should be enabled to start at boot.
Valid values are 'true', 'false', 'manual'.

- *Default*: 'true'

### Optional parameters. See [type reference](http://docs.puppetlabs.com/references/stable/type.html#service) for more information.

`binary`, `control`, `hasrestart`, `hasstatus`, `manifest`, `path`, `pattern`, `provider`, `restart`, `start`, `status`, `stop`

===

# Hiera

## cron
<pre>
types::crons:
  'clean puppet filebucket':
    command: '/usr/bin/find /var/lib/puppet/clientbucket/ -type f -mtime +30 -exec /bin/rm -fr {} \;'
    hour: 0
    minute: 0
  'purge old puppet dashboard reports':
    command: '/usr/bin/rake -f /usr/share/puppet-dashboard/Rakefile RAILS_ENV=production reports:prune upto=30 unit=day >> /var/log/puppet/dashboard_maintenance.log'
    hour: 0
    minute: 30
</pre>

## file
<pre>
types::files:
  '/tmp/foo':
    ensure: 'file'
  '/tmp/dir':
    ensure: 'directory'
  '/tmp/link':
    ensure: 'link'
    target: '/tmp/foo'
</pre>

## mount
<pre>
types::mounts:
  /mnt:
    device: /dev/dvd
    fstype: iso9660
    atboot: no
    remounts: true
  /srv/nfs/home:
    device: nfsserver:/export/home
    fstype: nfs
    options: rw,rsize=8192,wsize=8192
</pre>

## service
<pre>
types::services:
  iptables:
    ensure: 'false'
    enable: 'false'
  ip6tables:
    ensure: 'false'
    enable: 'false'
  tailored_firewalls:
    ensure: 'true'
    enable: 'true'
</pre>
