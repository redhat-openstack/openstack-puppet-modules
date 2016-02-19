# MidoNet

NOTE: This repository master now lives in [Openstack's
github](https://github.com/openstack/puppet-midonet)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What MidoNet affects](#what-midonet-affects)
    * [Beginning with MidoNet](#beginning-with-midonet)
4. [Usage](#usage)
5. [Reference](#reference)
    * [Classes](#classes)
    * [Types](#types)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

Puppet module for install MidoNet components.

## Module Description

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. This module provides the puppet
manifests to install all the components to deploy easily MidoNet in a
production environment.

To know all the components and how they relate each other, check out [midonet
reference architecture
docs](http://docs.midonet.org/docs/latest/reference-architecture/content/index.html)

## Setup

### What MidoNet affects

* This module affects the repository sources of the target system as well as
  new packages and their configuration files.

### Beginning with MidoNet

To install the last stable release of MidoNet OSS, just include the
MidoNet class in your Puppet manifest:

    include midonet

That will deploy a full MidoNet installation (repos, cassandra, zookeeper,
agent, MidoNet API and MidoNet CLI) in the target host, which is quite
useless deployment, since MidoNet is a network controller ready to be scalable
and distributed. However, for testing its features and demo purposes, it can
be useful.

## Usage

To use this module in a more advanced way, please check out the
[reference](#reference) section of this document. It is worth to highlight that
all the input variables have already a default input value, in a yaml document.
(We use R.I.Piennar [module data](https://www.devco.net/archives/2013/12/08/better-puppet-modules-using-hiera-data.php))
To leverage this feature, please add the following in your `/etc/puppet/hiera.yaml`
(or the Hiera configuration file that you are using):

    ---
    :backends:
      - yaml
      - module_data
    :yaml:
      :datadirs:
      - /var/lib/hiera
    :logger: console

Any variable that you may use in your class declaration will override the
defaults in `/etc/puppet/modules/midonet/data`, so you will only need to define
the variables that you want to override.

## Reference

### Classes

#### MidoNet Repository

MidoNet Repository adds MidoNet's repos into target system. By default it installs
last released version of MidoNet:

To install other releases than the last default's MidoNet OSS, you can override the
default's midonet\_repository atributes by a resource-like declaration:

    class { 'midonet_repository':
        midonet_repo            => 'http://repo.midonet.org/midonet/v2014.11',
        midonet_openstack_repo  => 'http://repo.midonet.org/openstack',
        midonet_thirdparty_repo => 'http://repo.midonet.org/misc',
        midonet_key             => '50F18FCF',
        midonet_stage           => 'stable',
        midonet_key_url         => 'http://repo.midonet.org/packages.midokura.key',
        openstack_release       => 'juno'
    }

or use a YAML file using the same attributes, accessible from Hiera:

    midonet_repository::midonet_repo: 'http://repo.midonet.org/midonet/v2014.11'
    midonet_repository::midonet_openstack_repo: 'http://repo.midonet.org/openstack'
    midonet_repository::midonet_thirdparty_repo: 'http://repo.midonet.org/misc'
    midonet_repository::midonet_key: '50F18FCF'
    midonet_repository::midonet_stage: 'stable'
    midonet_repository::midonet_key_url: 'http://repo.midonet.org/packages.midokura.key'
    midonet_repository::openstack_release: 'juno'


#### MidoNet Agent

MidoNet Agent is the Openvswitch datapath controller and must run in all the Hypervisor hosts.

The easiest way to run the class is:

     include midonet::midonet_agent

This call assumes that there is a zookeeper instance and a cassandra instance
running in the target machine, and will configure the midonet-agent to
connect to them.

This is a quite naive deployment, just for demo purposes. A more realistic one
would be:

    class {'midonet::midonet_agent':
      cassandra_seeds => ['host1', 'host2', 'host3'],
      zk_servers      => [{'ip'   => 'host1', 'port' => '2183'},
                          {'ip'   => 'host2', 'port' => '2181'}]
    }

Please note that Zookeeper port's value is not mandatory and it's already defaulted to 2181

You can alternatively use the Hiera's yaml style:

    midonet::midonet_agent::zk_servers:
        - ip: 'host1'
          port: 2183
        - ip: 'host2'
          port: 2181
    midonet::midonet_agent::cassandra_seeds:
        - 'host1'
        - 'host2'
        - 'host3'

Note: midonet\_agent class already makes a call to midonet\_agent::install.
This class allows to choose whether you want it to install and manage Java, or
use an existing installations instead.

For this purpose a param has been added and its value has been defaulted to
'true'. Should you want to manage the Java installation from another puppet
module and avoid duplicated class declaration, change the value to 'false':

    class { 'midonet::midonet_agent::install':
      install_java      => false
    }

You can alternatively use the Hiera's yaml style:

  midonet::midonet_agent::install::install_java: false

#### MidoNet API

MidoNet API is the REST service where third-party software can connect to
control the virtual network. A single instance of it can be enough.

The easiest way to run this class is:

    include midonet::midonet_api

This call assumes that there is a zookeeper running in the target host and the
module will spawn a midonet\_api without keystone authentication.

This is a quite naive deployment, just for demo purposes. A more realistic one
would be:

    class {'midonet::midonet_api':
        zk_servers           =>  [{'ip'   => 'host1', 'port' => '2183'},
                                  {'ip'   => 'host2', 'port' => '2181'}],
        keystone_auth        => true,
        vtep                 => true,
        api_ip               => '92.234.12.4',
        keystone_host        => '92.234.12.9',
        keystone_port        => '35357', # Note: (35357 is already the default)
        keystone_admin_token => 'arrakis',
        keystone_tenant_name => 'other-than-services' # Note: ('services' by default)
    }

You can alternatively use the Hiera's yaml style:

    midonet::midonet_api::zk_servers:
        - ip: 'host1'
          port: 2183
        - ip: 'host2'
          port: 2181
    midonet::midonet_api::vtep: true
    midonet::midonet_api::keystone_auth: true
    midonet::midonet_api::api_ip: '92.234.12.4'
    midonet::midonet_api::keystone_host: '92.234.12.9'
    midonet::midonet_api::keystone_port: 35357
    midonet::midonet_api::keystone_admin_token: 'arrakis'
    midonet::midonet_api::keystone_tenant_name: 'other-than-services'

Please note that Zookeeper port is not mandatory and defaulted to 2181.

Note: midonet\_api class already makes a call to midonet\_api::install. This
class allows you to choose whether you want it to install and manage Tomcat and
Java, or use existing installations of both instead.

For this purpose 2 parameters have been added and their values have been
defaulted to 'true'. Should you want to manage Tomcat and Java installation
from another puppet module and avoid duplicated class declaration, change the
values to 'false':

    class { 'midonet::midonet_api::install':
      install_java      => false,
      manage_app_server => false
    }

You can alternatively use the Hiera's yaml style:

  midonet::midonet_api::install::install_java: false
  midonet::midonet_api::install::manage_app_server: false

#### MidoNet CLI

Install the MidoNetCLI this way:

    include midonet::midonet_cli

Module does not configure the ~/.midonetrc file that `python-midonetclient`
needs to run. Please, check out how to configure the MidoNet client
[here](http://docs.midonet.org/docs/latest/quick-start-guide/rhel-7_juno-rdo/content/_midonet_cli_installation.html)

#### Neutron Plugin

Install and configure MidoNet Neutron Plugin. Please note that manifest does
install Neutron (because it is a requirement of 'python-neutron-plugin-midonet'
package) but it does not configure it nor run it. It just configure the specific
MidoNet plugin files. It is supposed to be deployed along any existing puppet
module that configures Neutron, such as [puppetlabs/neutron](https://forge.puppetlabs.com/puppetlabs/neutron/4.1.0)

The easiest way to run this class is:

    include midonet::neutron_plugin

Although it is quite useless: it assumes that there is a Neutron server already
configured and a MidoNet API running at localhost with Mock authentication.

A more advanced call would be:

    class {'midonet::neutron_plugin':
        midonet_api_ip => '23.123.5.32',
        username       => 'neutron',
        password       => '32kjaxT0k3na',
        project_id     => 'service'
    }

You can alternatively use the Hiera's yaml style:

    midonet::neutron_plugin::midonet_api_ip: '23.213.5.32'
    midonet::neutron_plugin::username: 'neutron'
    midonet::neutron_plugin::password: '32.kjaxT0k3na'
    midonet::neutron_plugin::midonet_api_ip: 'service'

### Types

#### MidoNet Host Registry ###

MidoNet defines Tunnel Zones as groups of hosts capable to send packages to
each other using networking tunnels from which we can create Virtual Networks
on the overlay.

Each host that runs [#MidoNet Agent] should be part of at least one Tunnel Zone
to send packets in the overlay to the rest of hosts of the Tunnel Zone. The
type `midonet_host_registry` allows you to register the host.

A [#MidoNet API] should already been deployed before and the [#MidoNet Agent]
should be running in the host we are registering.

This is the way to use it:

    midonet_host_registry {$::fqdn:
      $ensure              => present,
      $midonet_api_url     => 'http://controller:8080',
      $username            => 'admin',
      $password            => 'admin',
      $tenant_name         => 'admin',
      $underlay_ip_address => '123.23.43.2'
      $tunnelzone_name     => 'tzone0',
      $tunnelzone_type     => 'gre'
    }

Notes:

 * **midonet\_api\_url**, **username**, **password**, **tenant\_\name**:
   Credentials to authenticate to Keystone through the MidoNet API service.
   **tenant\_name** is defaulted to **admin** and is not mandatory.
 * **underlay\_ip\_address**: Physical interface from where the packets will be
   tunneled.
 * **tunnelzone\_name**: Name of the Tunnel Zone. If the Tunnel Zone is does
   not exist, the provider will create it. Defaulted to *tzone0*, so is not
   mandatory to use this attribute unless you care too much about names or you
   want more than one Tunnel Zone.
 * **tunnelzone\_type**: Type of the tunnel. You can choose between *gre* and
   *vxlan*. Defaulted to 'gre'.

 More info at MidoNet
 [docs|http://docs.midonet.org/docs/latest/quick-start-guide/ubuntu-1404_kilo/content/_midonet_host_registration.html]

#### MidoNet Gateway ####

This capability allows a Host that runs MidoNet to be declared as the gateway
of the installation and provide the necessary steps to put the packages from
the underlay to the overlay and viceversa. MidoNet needs to bind a Host
interface to *MidoNet Provider Router*, which is the router on top of the
Virtual Infrastructure.

Then, MidoNet starts BGP sessions to advertise the routes that manages and be
accessible from the Internet.

This is the way to use it:

    midonet_gateway {$::fqdn:
      ensure          => present,
      midonet_api_url => 'http://controller:8080',
      username        => 'admin',
      password        => 'admin',
      tenant_name     => 'admin',
      interface       => 'eth1',
      local_as        => '64512',
      bgp_port        => { 'port_address' => '198.51.100.2', 'net_prefix' => '198.51.100.0', 'net_length' => '30'},
      remote_peers    => [ { 'as' => '64513', 'ip' => '198.51.100.1' },
                           { 'as' => '64513', 'ip' => '203.0.113.1' } ],
      advertise_net   => [ { 'net_prefix' => '192.0.2.0', 'net_length' => '24' } ]
    }

More info at MidoNet
[docs|http://docs.midonet.org/docs/latest/quick-start-guide/ubuntu-1404_kilo/content/bgp_uplink_configuration.html]

 * **midonet\_api\_url**, **username**, **password**, **tenant\_\name**:
   Credentials to authenticate to Keystone through the MidoNet API service.
   **tenant\_name** is defaulted to **admin** and is not mandatory.
 * **interface**: Host Interface where the gateway port of the  *MidoNet
   Provider Router* will be binded.
 * **local_as**: Local Autonomous System of MidoNet deployment.
 * **bgp_port**: Information about the port that will be created on *MidoNet
   Provider Router* and will serve as the gateway of the virtual
   infrastructure.
 * **remote_peers**: List of uplink peers to establish BGP connections to.
 * **advertise_net**: List of Network that will be advertised on from MidoNet
   on the BGP sessions.


## Limitations

This module supports:

  * Ubuntu 14.04
  * CentOS 6.6
  * CentOS 7

This module has been tested in Puppet 3.7.3 version, but we believe that it
should work without problems in any Puppet 3.x version.

## Development

We happily will accept patches and new ideas to improve this module.

Check out current bugs or open new ones on JIRA project:

    https://midonet.atlassian.net/projects/PUP

Feel free to assign an empty one to yourself!

Clone MidoNet's puppet repo in:

    git clone https://github.com/midonet/puppet-midonet.git

and send patches via:

    git review

You can see the state of the patch in:

    https://review.gerrithub.io/#/q/status:open+project:midonet/puppet-midonet

We are using a Gerrit's rebase-based branching policy. So please, submit a
single commit per change. If a commit has been rejected, do the changes you
need to do and squash your changes with the previous patch:

    git commit --amend

We are using beaker for integration testing, puppet-lint for syntax code
convention and rspec por unit testing. To test the module before send a patch,
we recommend to use [bundle](http://bundler.io/) to install the dependencies:

    $ gem install bundle $ cd <path_to_puppet-midonet> $ bundle install

And then run the syntax, unit, and smoke tests.

    $ rake lint $ rake spec $ rake beaker

**Puppet-midonet** uses Docker as the backend provisioner for beaker, so to
have Docker installed is mandatory.

Ping us on **#installers** channel on http://midonet.atlassian.org

## Release Notes

* v2015.1.0: Initial manifests
* v2015.6.0: Adding `midonet_cli`, `midonet_host_registry` and
  `midonet_gateway` types.
