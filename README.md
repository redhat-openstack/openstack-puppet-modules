#puppet-zookeeper

[![Build Status](https://travis-ci.org/deric/puppet-zookeeper.png?branch=master)](https://travis-ci.org/deric/puppet-zookeeper)

A puppet receipt for [Apache Zookeeper](http://zookeeper.apache.org/). ZooKeeper is a high-performance coordination service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.

## Requirements

  * Puppet 2.7, Puppet 3.x
  * Ruby 1.8.7, 1.9.3, 2.0.0
  * binary package of zookeeper

### Debian/Ubuntu

  * Debian 6 Squeeze: you can get ZooKeeper package from [Wheezy](http://packages.debian.org/wheezy/zookeeper) or [Sid](http://packages.debian.org/sid/zookeeper) repo.
  * Debian 7 Wheezy: available in apt repository

## Basic Usage:

```puppet
class { 'zookeeper': }
```

If `$::ipaddress` is not your public IP (e.g. you are using Docker) make sure to setup correct IP:

```puppet
class { 'zookeeper':
  client_ip => $::ipaddress_eth0
}
```

or in Hiera:

```yaml
zookeeper::client_ip: "%{::ipaddress_eth0}"
```

##  Parameters

   - `id` - cluster-unique zookeeper's instance id (1-255)
   - `datastore`
   - `log_dir`
   - `purge_interval` - automatically will delete zookeeper logs (available since 3.4.0)
   - `snap_retain_count` - number of snapshots that will be kept after purging (since 3.4.0)

and many others, see the `init.pp` file for more details.

## Hiera Support

All parameters could be defined in hiera files, e.g. `common.yaml`, `Debian.yaml` or `zookeeper.yaml`:

```yaml
zookeeper::id: 1
zookeeper::client_port: 2181
zookeeper::datastore: '/var/lib/zookeeper'
```

## Install

### librarian (recommended)

For [puppet-librarian](https://github.com/rodjek/librarian-puppet) just add to `Puppetfile`

```ruby
mod 'zookeeper', :git => 'git://github.com/deric/puppet-zookeeper.git'
```

### submodules

If you are versioning your puppet conf with git just add it as submodule, from your repository root:

    git submodule add git://github.com/deric/puppet-zookeeper.git modules/zookeeper

## Dependencies

  * stdlib `> 2.3.3` - function `ensure_resources` is required

## Supported platforms

  * Debian/Ubuntu

### Tested on:

  * Debian 6 Squeeze, Puppet 3.1.0, Zookeeper 3.3.5
  * Debian 7 Wheezy
  * Ubuntu 12.04.03 LTS


