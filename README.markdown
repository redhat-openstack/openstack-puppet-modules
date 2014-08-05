# Uchiwa-Puppet

Tested with Travis CI

[![Build Status](https://travis-ci.org/pauloconnor/pauloconnor-uchiwa.png)](https://travis-ci.org/sensu/sensu-puppet)

## Installation

    $ puppet module install pauloconnor-uchiwa

## Prerequisites
- One or more working Sensu installations

### Dependencies
- puppetlabs/apt
- puppetlabs/stdlib

See `Modulefile` for details.

## Basic example

### Sensu server

    node 'uchiwa-server.foo.com' {
      class { 'uchiwa':
      }
    }

## Advanced example using multiple APIs

    node 'uchiwa-server.foo.com' {
      class { 'uchiwa': 
        apis => {
          'API 1' => 
            {
              name    => 'API 1',
              host    => '10.56.5.8',
              ssl     => false,
              port    => 4567,
              user    => 'sensu',
              pass    => 'sensu',
              path    => '',
              timeout => 5000
            },
          'API 2' => 
            {
              name    => 'API 2',
              host    => '10.16.1.25',
              ssl     => false,
              port    => 4567,
              user    => 'sensu',
              pass    => 'sensu',
              path    => '',
              timeout => 5000
            } 
        }
    }

## License

See LICENSE file.
