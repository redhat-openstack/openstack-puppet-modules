# Uchiwa-Puppet

Tested with Travis CI

[![Build Status](https://travis-ci.org/Yelp/yelp-uchiwa.png)](https://travis-ci.org/yelp/yelp-uchiwa)

## Upgrade Note

Versions greater than 0.2.0 are incompatible with previous versions of the Sensu-Puppet module.

## Installation

    $ puppet module install yelp-uchiwa

## Prerequisites
- One or more working Sensu installations

### Dependencies
- puppetlabs/apt
- puppetlabs/stdlib
- richardc/datacat

See `Modulefile` for details.

## Basic example

### Sensu server

    node 'uchiwa-server.foo.com' {
      class { 'uchiwa':
      }
    }

## Advanced example using multiple APIs

API definitions will default to the following values:

    name    => Definition Name
    host    => ''
    ssl     => false
    port    => 4567
    user    => 'sensu'
    pass    => 'sensu'
    path    => ''
    timeout => 5000

This is an example of a 2 API setup:

    node 'uchiwa-server.foo.com' {
      class { 'uchiwa': }

      uchiwa::api { ' API 1':
        host    => '10.56.5.8',
      }

      uchiwa::api { 'API 2':
        host    => '10.16.1.25',
        ssl     => true,
        port    => 7654,
        user    => 'sensu',
        pass    => 'saBEnX8PQoyz2LG',
        path    => '/sensu',
        timeout => 5000
      }
    }

## License

See LICENSE file.
