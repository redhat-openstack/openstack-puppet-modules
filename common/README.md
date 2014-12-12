# puppet-module-common #

[![Build Status](
https://api.travis-ci.org/ghoneycutt/puppet-module-common.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-common)

common module to be applied to **ALL** nodes

# Compatibility #

Module is generic enough to work on any system, though the individual modules that it could potentially include could be very platform specific.

===

# Common class #
Optionally include classes that are common to all systems, such as `dnsclient`, `ntp`, `puppet::agent`, and `vim`. By default we do not take any action, so you must enable the classes. This should be done in Hiera such as the following example. Ideally you would do this in your least specific level of hiera (often times labeled as 'common' or 'global') and potentially override at other levels.

<pre>
---
common::manage_root_password: true
common::enable_dnsclient: true
common::enable_ntp: true
common::enable_puppet_agent: true
common::enable_vim: true
</pre>

## Parameters for class `common`##

users
-----
Hash of users to ensure with common::mkusers

- *Default*: undef

groups
------
Hash of groups to ensure

- *Default*: undef

manage_root_password
--------------------

- *Default*: false

root_password
-------------

- *Default*: MD5 crypt of `puppet`

create_opt_lsb_provider_name_dir
--------------------------------
Boolean to ensure `/opt/${lsb_provider_name}`

- *Default*: false

lsb_provider_name
-----------------
LSB Provider Name as assigned by LANANA - [http://www.lanana.org/lsbreg/providers/index.html](http://www.lanana.org/lsbreg/providers/index.html)

- *Default*: `UNSET`

enable_dnsclient
----------------
Boolean to include ghoneycutt/dnsclient

- *Default*: false

enable_hosts
------------
Boolean to include ghoneycutt/hosts

- *Default*: false

enable_inittab
--------------
Boolean to include ghoneycutt/inittab

- *Default*: false

enable_mailaliases
------------------
Boolean to include ghoneycutt/mailaliases

- *Default*: false

enable_motd
-----------
Boolean to include ghoneycutt/motd

- *Default*: false

enable_network
--------------
Boolean to include ghoneycutt/network

- *Default*: false

enable_nsswitch
---------------
Boolean to include ghoneycutt/nsswitch

- *Default*: false

enable_ntp
----------
Boolean to include ghoneycutt/ntp

- *Default*: false

enable_pam
----------
Boolean to include ghoneycutt/pam

- *Default*: false

enable_puppet_agent
-------------------
Boolean to include ghoneycutt/puppet::agent

- *Default*: false

enable_rsyslog
--------------
Boolean to include ghoneycutt/rsyslog

- *Default*: false

enable_selinux
--------------
Boolean to include ghoneycutt/selinux

- *Default*: false

enable_ssh
----------
Boolean to include ghoneycutt/ssh

- *Default*: false

enable_utils
------------
Boolean to include ghoneycutt/utils

- *Default*: false

enable_vim
----------
Boolean to include ghoneycutt/vim

- *Default*: false

enable_wget
-----------
Boolean to include ghoneycutt/wget

- *Default*: false

### includes classes based on `osfamily` fact ###

enable_debian
-----------
Boolean to include ghoneycutt/debian

- *Default*: false

enable_redhat
-----------
Boolean to include ghoneycutt/redhat

- *Default*: false

enable_solaris
-----------
Boolean to include ghoneycutt/solaris

- *Default*: false

enable_suse
-----------
Boolean to include ghoneycutt/suse

- *Default*: false

===

# common::mkdir_p define #
Provide `mkdir -p` functionality for a directory.

Used in conjunction with a file resource.

## Example usage: ##
<pre>
common::mkdir_p { '/some/dir/structure': }

file { '/some/dir/structure':
  ensure  => directory,
  require => Common::Mkdir_p['/some/dir/structure'],
}
</pre>

## Parameters for `common::mkdir_p` define ##

None.

===

# common::remove_if_empty define #
Removes a file if it exists and is empty.

## Example usage: ##
<pre>
common::remove_if_empty { '/path/to/potentially_empty_file': }
</pre>

## Parameters for `common::remove_if_empty` define ##

None.

===

# common::mkuser define #
Ensures user/groups

## Usage ##
You can specify hash each for users and groups and use Hiera to manage them.

This example uses the YAML backend, though that is not mandatory.

In Hiera's hierarchy add two levels, `users`, and `groups` such as the following example.

`hiera.yaml`
<pre>
---
:backends:
  - yaml
:hierarchy:
  - fqdn/%{fqdn}
  - users
  - groups
  - %{environment}
  - common
:yaml:
  :datadir:
</pre>

`users.yaml`
<pre>
---
common::users:
  gh:
    uid: "30000"
    comment: "Garrett Honeycutt"
    groups: admin
    ssh_auth_key: ssh-public-key
</pre>

`groups.yaml`
<pre>
---
common::groups:
  admin:
    gid: "32000"
</pre>


## Parameters for `common::mkuser` define ##

uid
---
String - UID of user

- *Required*

gid
---
String - GID of user

- *Default*: `$uid`

name
----
String - username

group
-----
String - group name of user

- *Default*: `$name`

shell
-----
String - user's shell

- *Default*: '/bin/bash'

home
------
String - home directory

- *Default*: `/home/${username}`

ensure
------
Present or Absent

- *Default*: present

managehome
----------
Boolean for manage home attribute of user resource

- *Default*: true

manage_dotssh
-------------
Boolean to optionally create `~/.ssh` directory

- *Default*: true

comment
-------
String - GECOS field for passed

- *Default*: 'created via puppet'

groups
------
Array - additional groups the user should be associated with

- *Default*: undef

password
--------
String - password crypt for user

- *Default*: '!!'

mode
----
String - mode of home directory

- *Default*: 0700

ssh_auth_key
-----------------
String - The ssh key for the user

- *Default*: undef

ssh_auth_key_type
-----------------
String - Anything that the ssh_authorized_key resource can take for the type attribute, such as `ssh-dss` or `ssh-rsa`.

- *Default*: 'ssh-dss'

===

# Functions #

## interface2factname() ##
Takes one argument, the interface name, and returns it formatted for use with facter.

Example: `interface2factname('bond0:0')` would return `ipaddress_bond0_0`.

## strip_file_extension() ##
Takes two arguments, a file name which can include the path, and the extension to be removed. Returns the file name without the extension as a string.

Example: `strip_file_extension('myapp.war','war')` would return `myapp`.

