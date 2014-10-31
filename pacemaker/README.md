# Pacemaker module for puppet

This module manages pacemaker on Linux distros with the pcs tool.

## License
Apache 2.0

## Support & Contact
Please log tickets and issues at https://github.com/radez/puppet-pacemaker

## Description

This module uses the fact osfamily which is supported by Facter 1.6.1+. If you do not have facter 1.6.1 in your environment, the following manifests will provide the same functionality in site.pp (before declaring any node):

    if ! $::osfamily {
      case $::operatingsystem {
        'RedHat', 'Fedora', 'CentOS', 'Scientific', 'SLC', 'Ascendos', 'CloudLinux', 'PSBM', 'OracleLinux', 'OVS', 'OEL': {
          $osfamily = 'RedHat'
        }
        'ubuntu', 'debian': {
          $osfamily = 'Debian'
        }
        'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
          $osfamily = 'Suse'
        }
        'Solaris', 'Nexenta': {
          $osfamily = 'Solaris'
        }
        default: {
          $osfamily = $::operatingsystem
        }
      }
    }

This module is based on work by Dan Radez

## Usage

### pacemaker
Installs Pacemaker and corosync and creates a cluster

    class {"pacemaker::corosync":
        cluster_name => "cluster_name",
        cluster_members => "192.168.122.3 192.168.122.7",
    }

The pacemaker::corosync resource must be executed on each node

### Disable stonith
    class {"pacemaker::stonith":
        disable => true,
    }

### Add a stonith device
    class {"pacemaker::stonith::ipmilan":
        address => "10.10.10.100",
        user => "admin",
        password => "admin",
    }

### Resources
Any of the following resources support a group propery.
This will create the group, if the group doesn't exist,
and add the resource to the group. This has been demonstrated
on the ip address example, but is not a required propery.

#### Add a floating ip
    pacemaker::resource::ip { "192.168.122.223":
        ip_address => "192.168.122.223",
        group => "my_group",
    }

#### Manage a Linux Standard Build service
#### That will get created after the floating ip
    pacemaker::resource::lsb { "http":
        require => Pacemaker::Resource::Ip['192.168.122.223'],
    }

#### Manage a MySQL server
    pacemaker::resource::mysql { "da-database": }

#### Manage a shared filesystem
    pacemaker::resource::filesystem { "apache share":
        device => "192.168.122.1:/var/www/html",
        directory => "/mnt",
        fstype => "nfs",
    }
