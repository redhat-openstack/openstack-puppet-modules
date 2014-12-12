# puppet-module-nfs #

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-nfs.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-nfs)

Puppet module to manage NFS client and server

## Components ##

### Server
----------
- Manage NFS server
- Setup of exports

### Idmap
---------
- Manage idmapd
- Setup of configuration for idmapd


## Compatibility ##

This module has been tested to work on the following systems with Puppet v3 and Ruby 1.8.7, 1.9.3, and 2.0.0.

 * Debian 6 (client only)
 * EL 5
 * EL 6
 * EL 7
 * Solaris 10
 * Solaris 11
 * Suse 10
 * Suse 11
 * Ubuntu 12.04 LTS

===

# Parameters #

hiera_hash
----------
Boolean to use hiera_hash which merges all found instances of nfs::mounts in Hiera. This is useful for specifying mounts at different levels of the hierarchy and having them all included in the catalog. This will default to `true` in future versions.

- *Default*: false

nfs_package
-----------
Name of the NFS package

- *Default*: Uses system defaults as specified in module

nfs_service
-----------
Name of the NFS service

- *Default*: Uses system defaults as specified in module

mounts
------
Hash of mounts to be mounted on system. See below.

- *Default*: undef

===

## Class `nfs::server` ##

### Parameters ###

exports_path
------------
The location of the config file.
- *Default*: /etc/exports

exports_owner
-------------
The owner of the config file.
- *Default*: root

exports_group
-------------
The group for the config file.
- *Default*: root

exports_mode
------------
The mode for the config file.
- *Default*: 0644

===

## Class `nfs::idmap` ##

### Parameters ###

idmap_package
-------------
String of the idmap package name.
- *Default*: Os specific

idmapd_conf_path
----------------
The location of the config file.
- *Default*: /etc/idmapd.conf

idmapd_conf_owner
-----------------
The owner of the config file.
- *Default*: root

idmapd_conf_group
-----------------
The group for the config file.
- *Default*: root

idmapd_conf_mode
----------------
The mode for the config file.
- *Default*: 0644

idmapd_service_name
-------------------
String of the service name.
- *Default*: rpcidmapd

idmapd_service_enable
---------------------
Boolean value of enable parameter for idmapd service.
- *Default*: true

idmapd_service_hasstatus
------------------------
Boolean value of hasstatus parameter for idmapd service.
- *Default*: true

idmapd_service_hasrestart
-------------------------
Boolean value of hasrestart parameter for idmapd service.
- *Default*: true

idmap_domain
------------
String value of domain to be set as local NFS domain.
- *Default*: $::domain

ldap_server
-----------
String value of ldap server name.
- *Default*: UNSET

ldap_base
---------
String value of ldap search base.
- *Default*: UNSET

local_realms
------------
String or array of local kerberos realm names.
- *Default*: $::domain

translation_method
------------------
String or array of mapping method to be used between NFS and local IDs.
Valid values is nsswitch, umich_ldap or static
- *Default*: nsswitch

nobody_user
-----------
String of local user name to be used when a mapping cannot be completed.
- *Default*: nobody

nobody_group
------------
String of local group name to be used when a mapping cannot be completed.
- *Default*: nobody

verbosity
---------
Integer of verbosity level.
- *Default*: 0

pipefs_directory
----------------
String of the directory for rpc_pipefs.
- *Default*: OS specific


===

# Manage mounts
This works by passing the nfs::mounts hash to the create_resources() function. Thus, you can provide any valid parameter for mount. See the [Type Reference](http://docs.puppetlabs.com/references/stable/type.html#mount) for a complete list.

## Example:
Mount nfs.example.com:/vol1 on /mnt/vol1 and nfs.example.com:/vol2 on /mnt/vol2

<pre>
nfs::mounts:
  /mnt/vol1:
    ensure: present
    device: nfs.example.com:/vol1
    options: rw,rsize=8192,wsize=8192
    fstype: nfs
  old_log_file_mount:
    name: /mnt/vol2
    ensure: present
    device: nfs.example.com:/vol2
    fstype: nfs
</pre>

## Creating Hiera data from existing system
This module contains `ext/fstabnfs2yaml.rb`, which is a script that will parse `/etc/fstab` and print out the nfs::mounts hash in YAML with which you can copy/paste into Hiera.
