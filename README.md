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

