#puppet-zookeeper


A puppet receipt for [Apache Zookeeper](http://zookeeper.apache.org/). ZooKeeper is a high-performance coordination service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.

Tested on Debian 6 Squeeze, Puppet 3.1.0, Zookeeper 3.3.5

## Requirements

  * puppet 3 (or puppet 2.7+ and hiera gem)
  * binary package of zookeeper
  
### Debian/Ubuntu
  
  * Debian 6 Squeeze: you can get ZooKeeper package from [Wheezy](http://packages.debian.org/wheezy/zookeeper) or [Sid](http://packages.debian.org/sid/zookeeper) repo.

## Basic Usage:

    class { 'zookeeper': }
    
##  Parameters

   - `myid` - cluster-unique zookeeper's instance id (1-255)
   - `datastore`
   - `log_dir`

All parameters should be defined in hiera files, e.g. `common.yaml`, `Debian.yaml`, ... Until `calling_module` syntax will work in hiera, you can use simplified scoping with prefixes:

     zookeeper_myid: 1
     zookeeper_datastore: '/var/lib/zookeeper'
     zookeeper_log_dir: '/var/log/zookeeper'
     zookeeper_java_bin: '/usr/bin/java'

With `calling_module` it would be enough to put in `zookeeper.yaml`:

     myid: 1
     client_port: 2181


For more parameters see `manifests/params.pp`

## Install

### librarian (recommended)

For [puppet-librarian](https://github.com/rodjek/librarian-puppet) just add to `Puppetfile`

    mod 'zookeeper', :git => 'git://github.com/deric/puppet-zookeeper.git'
    
### submodules    

If you are versioning your puppet conf with git just add it as submodule, from your repository root:

    git submodule add git://github.com/deric/puppet-zookeeper.git modules/zookeeper

    