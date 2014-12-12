# libvirt Module

This module manages software to install and configure libvirt from within 
Puppet. 

### Overview

This is the Puppet libvirt module. Here we are providing capability within 
Puppet to install and configure libvirt on a host machine.

It does not take care of the creation of virtual instances - if you wish to
manage instances directly in Puppet use:

https://github.com/carlasouza/puppet-virt

### Disclaimer

Warning! While this software is written in the best interest of quality it has 
not been formally tested by our QA teams. Use at your own risk, but feel free 
to enjoy and perhaps improve it while you do.

Please see the included Apache Software License for more legal details 
regarding warranty.

### Requirements

So this module was predominantly tested on:

* Puppet 2.7.0rc4
* Debian Wheezy
* libvirt 0.9.0

Other combinations may work, and we are happy to obviously take patches to 
support other stacks.

# Installation

As with most modules, its best to download this module from the forge:

http://forge.puppetlabs.com/puppetlabs/libvirt

If you want the bleeding edge (and potentially broken) version from github, 
download the module into your modulepath on your Puppetmaster. If you are not 
sure where your module path is try this command:

    puppet --configprint modulepath

Depending on the version of Puppet, you may need to restart the puppetmasterd 
(or Apache) process before the functions will work.

# Quick Start

Setup libvirt.

    node "kvm1" {
        class { "libvirt": }
    }

Setup and configure libvirt:

    node "kvm1" {
      class { libvirt:
        libvirtd_config => {
          max_clients => { value => 10 },
        },
        qemu_config => {
          vnc_listen => { value => "0.0.0.0" },
        },
      }
    }
    
# Detailed Usage

## Classes

### libvirt

The libvirt class is responsible for installing and setting up libvirt on a 
host.

#### Parameters

##### libvirtd_config

This parameter allows you to pass a hash that is passed to the 
libvirt::libvirtd_config resource.

##### qemu_config

This parameter allows you to pass a hash that is passed to the 
libvirt::qemu_config resource.

#### Examples

Basic example:

    class { "libvirt": }
    
Example with libvirtd_config parameters for configuring your libvirtd.conf 
file:

    class { "libvirt": 
      libvirtd_config => {
        max_clients => { value => 5 },
        tcp_port => { value => "16666" },
      }
    }

Example with qemu_config parameters for configuring your qemu.conf file:

    class { "libvirt":
      qemu_config => {
        vnc_port_listen => { value => "0.0.0.0" },
      }
    }
    
## Resources

### libvirt::libvirtd_config

This resource can be used to configure libvirt by populating items in the 
libvirtd.conf file.

### libvirt::qemu_config

This resource can be used to configure libvirt by populating items in the 
qemu.conf file.