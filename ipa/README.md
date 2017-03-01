# IPA Puppet module
[![Build Status](https://travis-ci.org/huit/puppet-ipa.png?branch=master)](https://travis-ci.org/huit/puppet-ipa)

## Overview

Puppet module that can manage an IPA master, replicas and clients.

huit/puppet-ipa aims at the management and configuration of a complete IPA environment under Puppet control.

To start, an IPA master will be required as the beginning of the LDAP/Kerberos environment. IPA replicas can
then be added for additional resiliancy.

The IPA primary master server will take a minimum of two Puppet runs to fully configure. This is because the ipa_adminhomedir,
ipa_adminuidnumber and ipa_replicascheme facts are not available until the IPA primary master is installed and operational.
These facts are necessary to automatically configure clients and replicas.

IPA replica servers will be automatically configured with a replication agreement on the IPA primary master server.

All Puppet nodes added as clients will automatically be added to the IPA domain through exported resources.

Multiple IPA domains are supported.

A cleanup parameter has been included to remove the IPA server or client packages from nodes.

## Dependencies

The ability to use [Exported resources](http://docs.puppetlabs.com/guides/exported_resources.html) and 
[Stored Configuration](http://projects.puppetlabs.com/projects/1/wiki/Using_Stored_Configuration) enabled on the Puppet master.

[puppetlabs/puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) module.

[puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) module.

## Usage

Available parameters.

####`master`

Configures a server to be an IPA master LDAP/Kerberos node.

Defaults to 'false'.

####`replica`

Configures a server to be an IPA replica LDAP/Kerberos node.

Defaults to 'false'.

####`client`

Configures a server to be an IPA client.

Defaults to 'false'.

####`cleanup`

Removes IPA specific packages.

Defaults to 'false'.

####`domain`

Defines the LDAP domain.

Defaults to 'undef'.

####`realm`

Defines the Kerberos realm.

Defaults to 'undef'.

####`adminpw`

Defines the IPA administrative user password.

Defaults to 'undef'.

####`dspw`

Defines the IPA directory services password.

Defaults to 'undef'.

####`otp`

Defines an IPA client one-time-password.

Defaults to 'undef'.

####`dns`

Controls the option to configure a DNS zone with the IPA master setup.

Defaults to 'false'.

####`fixedprimary`

Configure sssd to use a fixed server as the primary IPA server.

Defaults to 'false'.

####`forwarders`

Defines an array of DNS forwarders to use when DNS is setup. An empty list will use the Root Nameservers.

Defaults to '[]'.

####`extca`

Controls the option to configure an external CA.

Defaults to 'false'

####`extcertpath`

Defines a file path to the external certificate file. Somewhere under /root is recommended.

Defaults to 'undef'

####`extcert`

The X.509 certificate in base64 encoded format.

Defaults to 'undef'

####`extcapath`

Defines a file path to the external CA certificate file. Somewhere under /root is recommended.

Defaults ro 'undef'

####`extcacert`

The X.509 CA certificate in base64 encoded format.

Defaults to 'undef'

####`dirsrv_pkcs12`

PKCS#12 file containing the Directory Server SSL Certificate, also corresponds to the Puppet fileserver path under fileserverconfig for $confdir/files/ipa

Defaults to 'undef'

####`http_pkcs12`

The PKCS#12 file containing the Apache Server SSL Certificate, also corresponds to the Puppet fileserver path under fileserverconfig for $confdir/files/ipa

Defaults to 'undef'

####`dirsrv_pin`

The password of the Directory Server PKCS#12 file.

Defaults to 'undef'

####`http_pin`

The password of the Apache Server PKCS#12 file.

Defaults to 'undef'

####`subject`

The certificate subject base.

Defaults to 'undef'

####`selfsign`

Configure a self-signed CA instance for issuing server certificates instead of using dogtag for certificates.

Defaults to 'false'

####`loadbalance`

Controls the option to include any additional hostnames to be used in a load balanced IPA client configuration.

Defaults to 'false'.

####`ipaservers`

Defines an array of additional hostnames to be used in a load balanced IPA client configuration.

Defaults to '[]'

####`mkhomedir`

Controls the option to create user home directories on first login.

Defaults to 'false'.

####`ntp`

Controls the option to configure NTP on a client.

Defaults to 'false'.

####`kstart`

Controls the installation of kstart.

Defaults to 'true'.

####`desc`

Controls the description entry of an IPA client.

Defaults to ''.

####`locality`

Controls the locality entry of an IPA client.

Defaults to ''.

####`location`

Controls the location entry of an IPA client.

Defaults to ''.

####`sssdtools`

Controls the installation of the SSSD tools package.

Defaults to 'true'.

####`sssdtoolspkg`

SSSD tools package name.

Defaults to 'sssd-tools'

####`sssd`

Controls the option to start the SSSD service if its not defined elsewhere. Note: Set to false if the SSSD service is defined in your site specific modules.

Defaults to 'true'.

####`sudo`

Controls the option to configure sudo in LDAP.

Defaults to 'false'.

####`sudopw`

Defines the sudo user bind password.

Defaults to 'undef'.

####`debiansudopkg`

Controls the installation of the Debian sudo-ldap package.

Defaults to 'true'.

####`automount`

Controls the option to configure automounter maps in LDAP.

Defaults to 'false'.

####`autofs`

Controls the option to start the autofs service and install the autofs package.

Defaults to 'false'.

####`svrpkg`

IPA server package name.

Defaults to 'ipa-server'.

####`clntpkg`

IPA client package name.

Defaults to 'ipa-client'.

####`ldaputils`

Controls the instalation of the LDAP utilities package.

Defaults to 'true'.

####`ldaputilspkg`

LDAP utilities package name.

Defaults to 'openldap-clients'.

## Usage examples

Here are a few simple usage examples. If you don't want to put your passwords in the clear, then use hiera/gpg.

IPA master:

```puppet
    node 'ipamaster.domain.name' {
      class { 'ipa':
        master  => true, # Only one master per Puppet master
        domain  => 'domain.name',
        realm   => 'DOMAIN.NAME',
        adminpw => 'somepasswd', # Cleartext example
        dspw    => hiera('some_passwd') # Using hiera
      }
    }
```

IPA replica:

```puppet
    node 'ipareplica1.domain.name' {
      class { 'ipa':
        replica => true, # Multiple replicas can be setup.
        domain  => 'domain.name',
        realm   => 'DOMAIN.NAME',
        adminpw => 'somepasswd',
        dspw    => 'somepasswd',
        otp     => 'onetimepasswd'
      }
    }
```

Another IPA replica:

```puppet
    node 'ipareplica2.domain.name' {
      class { 'ipa':
        replica => true,
        domain  => 'domain.name',
        realm   => 'DOMAIN.NAME',
        adminpw => hiera('some_passwd'),
        dspw    => hiera('some_passwd'), 
        otp     => hiera('one_time_passwd')
      }
    }
```

IPA client:

```puppet
    node 'ipaclient.domain.name' {
      class { 'ipa':
        client      => true,
        domain      => 'domain.name',
        realm       => 'DOMAIN.NAME',
        loadbalance => true,
        ipaservers  => ['ipaloadbalanceddnsname.domain.name','ipamaster.domain.name','ipareplica1.domain.name','ipareplica2.domain.name'],
        desc        => 'This is an IPA client', # This string will show up the the description attribute of the computer account.
        otp         => hiera('one_time_passwd')
      }
    }
```

Cleanup parameter:

```puppet
    node 'ipawhatever.domain.name' {
      class { 'ipa':
        cleanup => true # Removes IPA completely. Mutually exclusive from master, replica and client parameters.
      }
    }
```

## Limitations

IPA master and replicas require a RedHat family OS.

Client configuration does not work with Ubuntu 8.04 and Ubuntu 10.04

## License

    huit/puppet-ipa - Puppet module that can manage an IPA master, replicas and clients.

    Copyright (C) 2013 Harvard University Information Technology

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

## Support

Please report issues [here](https://github.com/huit/puppet-ipa/issues).

For more information see [https://github.com/huit/puppet-ipa.git](https://github.com/huit/puppet-ipa.git)
