# Uchiwa-Puppet

Tested with Travis CI

[![Build Status](https://travis-ci.org/Yelp/puppet-uchiwa.svg?branch=master)](https://travis-ci.org/Yelp/puppet-uchiwa)

## Upgrade Note

Versions greater than 0.3.0 are incompatible with previous versions of the Yelp-Uchiwa module.

## Installation

    $ puppet module install yelp-uchiwa

## Prerequisites
- One or more working Sensu installations

### Dependencies
- puppetlabs/apt
- puppetlabs/stdlib

See `Modulefile` for details.

## Examples

### Simple Setup

By default the puppet module will connect to a single Sensu API endpoint on
localhost:

```puppet
node 'uchiwa-server.foo.com' {
  include ::uchiwa
}
```

API definitions will default to the following values:

    name     => 'sensu'
    host     => '127.0.0.1'
    ssl      => false
    insecure => false
    port     => 4567
    user     => 'sensu'
    pass     => 'sensu'
    path     => ''
    timeout  => 5

### Simple Server Without the Repo

The module itself sets up the Sensu repo in order to download Uchiwa. Often this
is also done by the Sensu puppet module too. To get around this duplication you
can ask the Uchiwa module not to manage the repo:

```puppet
class { '::uchiwa':
  install_repo => false,
}
```

### Advanced Example Using Multiple APIs

This is an example of how to setup Uchiwa connecting
to two different API endpoints. In this example there is
one endpoint using mostly default parameters, and then
a second endpoint using all the possible options:

```puppet
node 'uchiwa-server.foo.com' {

  $uchiwa_api_config = [
    {
      host  => '10.56.5.8',
    },
    {
      host      => '10.16.1.25',
      ssl       => true,
      insecure  => true,
      port      => 7654,
      user      => 'sensu',
      pass      => 'saBEnX8PQoyz2LG',
      path      => '/sensu',
      timeout   => 5
    }
  ]
  class { 'uchiwa':
    sensu_api_endpoints => $uchiwa_api_config,
  }
}
```

## License

See LICENSE file.
