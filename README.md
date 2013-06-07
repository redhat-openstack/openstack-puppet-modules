# IPA Puppet module

**Puppet module that allows the creation of IPA master, replicas and clients.**

## Dependencies

IPA master and replicas require a RedHat family OS

[Exported resources](http://docs.puppetlabs.com/guides/exported_resources.html) on the Puppet master

[puppetlabs/puppetlabs-firewall](https://github.com/puppetlabs/puppetlabs-firewall) module

## Usage

Here is a simple usage example. If you don't want to put your passwords in the clear, then use hiera/gpg.

    node 'ipamaster.domain.name' {
        class {
            'ipa':
                master  => true,
                domain  => 'domain.name',
                realm   => 'DOMAIN.NAME',
                adminpw => 'somepasswd',
                dspw    => hiera('some_passwd')
        }
    }

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
