# IPA Puppet module

## Overview

Puppet module that allows the creation of IPA master, replicas and clients.

All nodes added as clients will automatically be added to the domain.

## Dependencies

[Exported resources](http://docs.puppetlabs.com/guides/exported_resources.html) on the Puppet master.

[puppetlabs/puppetlabs-firewall](https://github.com/puppetlabs/puppetlabs-firewall) module.

## Usage

Here are a few simple usage examples. If you don't want to put your passwords in the clear, then use hiera/gpg.

IPA master:

    node 'ipamaster.domain.name' {
        class {
            'ipa':
                master  => true, # Only one master per Puppet master
                domain  => 'domain.name',
                realm   => 'DOMAIN.NAME',
                adminpw => 'somepasswd', # Cleartext example
                dspw    => hiera('some_passwd') # Using hiera
        }
    }

IPA replica:

    node 'ipareplica1.domain.name' {
        class {
            'ipa':
                replica => true, # Multiple replicas can be setup.
                domain  => 'domain.name',
                realm   => 'DOMAIN.NAME',
                adminpw => 'somepasswd',
                dspw    => 'somepasswd',
                otp     => 'onetimepasswd'
        }
    }

Another IPA replica:

    node 'ipareplica2.domain.name' {
        class {
            'ipa':
                replica => true,
                domain  => 'domain.name',
                realm   => 'DOMAIN.NAME',
                adminpw => hiera('some_passwd'),
                dspw    => hiera('some_passwd'), 
                otp     => hiera('one_time_passwd')
        }
    }

IPA client:

    node 'ipaclient.domain.name' {
        class {
            'ipa':
                client  => true,
                domain  => 'domain.name',
                realm   => 'DOMAIN.NAME',
                desc    => 'This is an IPA client', # This string will show up the the description attribute of the computer account.
                otp     => hiera('one_time_passwd')
        }
    }

Cleanup parameter:

    node 'ipawhatever.domain.name' {
        class {
            'ipa':
                cleanup => true # Removes IPA completely. Mutually exclusive from master, replica and client parameters.
        }
    }

## Limitations

IPA master and replicas require a RedHat family OS.

Only one IPA master server can be defined per Puppet master.

Only one IPA domain/realm can be defined per Puppet master.

## License

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

For more information see https://github.com/huit/puppet-ipa.git
