#puppet-zookeeper


A puppet receipt for zookeeper. You should fetch last version of Zookeeper from web http://zookeeper.apache.org/releases.html#download and place it to `modules/zookeeper/files`

Tested on Debian 6 Squeeze, Puppet 3.1.0, Zookeeper 3.4.5

## Basic Usage:

    class { 'zookeeper':
      myid    => '1',
      version => '3.4.5'
    }

You can override any of the defaults:

    class { 'zookeeper':
      myid          => '1',
      datastore     => "/usr/lib/zookeeper/data",
      datastore_log => "/var/log/zookeeper/datastore",
      log_dir       => "/var/log/zookeeper",
    }

For more parameters see `manifests/params.pp`

## Install

If you are versioning your puppet conf with git (which you probably should) just add it as submodule, from your repository root:

    git submodule add git://github.com/deric/puppet-zookeeper.git modules/zookeeper
    
## TODO 

  - fetch releases automatically from apache website