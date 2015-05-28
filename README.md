# midonet

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What midonet affects](#what-midonet-affects)
    * [Beginning with midonet](#beginning-with-midonet)
4. [Usage](#usage)
5. [Reference](#reference)
    * [Midonet Repository Class Reference](#midonet-repository)
    * [Cassandra Class Reference](#cassandra)
    * [Zookeeper Class Reference](#zookeeper)
    * [Midonet Agent Class Reference](#midonet-agent)
    * [Midonet API Class Reference](#midonet-api)
    * [Midonet CLI Class Reference](#midonet-cli)
    * [Neutron Plugin Class Reference](#neutron-plugin)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

Puppet module for install midonet components.

## Module Description

MidoNet is an Apache licensed production grade network virtualization software
for Infrastructure-as-a-Service (IaaS) clouds. This module provides the puppet
manifests to install all the components to deploy easily MidoNet in a production
environment.

To know all the components and how they relate each other, check out [midonet
reference architecture
docs](http://docs.midonet.org/docs/latest/reference-architecture/content/index.html)

## Setup

### What midonet affects

* This module affects the respository sources of the target system as well as
  new packages and their configuration files.

### Beginning with midonet

To install the last stable release of Midonet OSS, just include the
midonet class in your Puppet manifest:

    include midonet

That will provide a full MidoNet installation (repos, cassandra, zookeeper,
agent, midonet api, and midonet cli) in the target host, which is quite
useless deployment, since MidoNet is a network controller ready to be scalable
and distributed. However, for testing its features and demo purposes, it would
be useful.

NOTE: The module also adds official OpenStack sources. It will use Icehouse or
Juno depending on to underlay OS: Juno is not supported in Ubuntu 12.04 nor
CentOS 6.x.

## Usage

To use this module in a more advanced way, please check out the
[reference](#reference) section of this document. It is worth to highlight that all
the input variables have already a default input value, in a yaml document.
(We use R.I.Piennar [module data](https://www.devco.net/archives/2013/12/08/better-puppet-modules-using-hiera-data.php))
To leverage this feature, please add the following in your `/etc/hiera.yaml` (or
the Hiera configuration file that you are using):

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

#### Midonet Repository

Midonet Repository adds midonet's repos into target system. By default it installs
last released version of midonet:

To install other releases than the last default's Midonet OSS, you can override the
default's midonet_repository atributes by a resource-like declaration:

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


#### Cassandra

MidoNet needs Cassandra cluster to keep track of living connections. This class
installs cassandra the way that MidoNet needs it.

The easiest way to run the class is:

    include midonet::cassandra

And a cassandra single-machine cluster will be installed, binding the
'localhost' address.

Run a single-machine cluster but binding a hostname or another address
would be:

    class {'midonet::cassandra':
        seeds        => ['192.168.2.2'],
        seed_address => '192.168.2.2'
    }

For cluster of nodes, use the same 'seeds' value, but change the
seed_address of each node:

... On node1:

    class {'midonet::cassandra':
        seeds        => ['node_1', 'node_2', 'node_3'],
        seed_address => 'node_1'
    }

... On node2:

    class {'midonet::cassandra':
        seeds        => ['node_1', 'node_2', 'node_3'],
        seed_address => 'node_2'
    }

... On node3:

    class {'midonet::cassandra':
        seeds        => ['node_1', 'node_2', 'node_3'],
        seed_address => 'node_3'
    }

NOTE: node_X can be either hostnames or ip addresses
You can alternatively use the Hiera's yaml style:

    midonet::cassandra::seeds:
        - node_1
        - node_2
        - node_3
    midonet::cassandra::seed_address: 'node_1'

#### Zookeeper

ZooKeeper cluster stores MidoNet virtual network hierarchy. Likewise
Cassandra, this class installs the version and configuration that MidoNet needs
to run.

The easiest way to run the class is:

     include midonet::zookeeper

And puppet will install a local zookeeper without cluster. For a clustered
zookeeper, the way you have to define your puppet site, is:

... on Node1

    class {'midonet::zookeeper':
        servers   =>  [{'id'   => 1
                        'host' => 'node_1'},
                       {'id'   => 2,
                        'host' => 'node_2'},
                       {'id'   => 3,
                        'host' => 'node_3'}],
        server_id => 1}

... on Node2

    class {'midonet::zookeeper':
        servers   =>  [{'id'   => 1
                        'host' => 'node_1'},
                       {'id'   => 2,
                        'host' => 'node_2'},
                       {'id'   => 3,
                        'host' => 'node_3'}],
        server_id => 2}

... on Node3

    class {'midonet::zookeeper':
        servers   =>  [{'id'   => 1
                        'host' => 'node_1'},
                       {'id'   => 2,
                        'host' => 'node_2'},
                       {'id'   => 3,
                        'host' => 'node_3'}],
        server_id => 3}

defining the same servers for each puppet node, but using a different
server\_id for each one. NOTE: node\_X can be hostnames or IP addresses.

you can alternatively use the Hiera's yaml style

    midonet::zookeeper::servers:
        - id: 1
          host: 'node_1'
        - id: 2
          host: 'node_2'
        - id: 3
          host: 'node_3'
    midonet::zookeeper::server_id: '1'

#### Midonet Agent

Midonet Agent is the Openvswitch datapath controller and must run in all the Hypervisor hosts.

The easiest way to run the class is:

     include midonet::midonet_agent

This call assumes that there is a zookeeper instance and a cassandra instance
running in the target machine, and will configure the midonet-agent to
connect to them.

This is a quite naive deployment, just for demo purposes. A more realistic one
would be:

    class {'midonet::midonet_agent':
        zk_servers              =>  [{'ip'   => 'host1',
                                      'port' => '2183'},
                                    {'ip'   => 'host2'}],
       cassandra_seeds         =>  ['host1', 'host2', 'host3']
    }

Please note that Zookeeper port is not mandatory and defaulted to 2181

You can alternatively use the Hiera's yaml style:

    midonet::midonet_agent::zk_servers:
        - ip: 'host1'
          port: 2183
        - ip: 'host2'
    midonet::midonet_agent::cassandra_seeds:
        - 'host1'
        - 'host2'
        - 'host3'


#### Midonet API

MidoNet API is the REST service where third-party software can connect to
control the virtual network. A single instance of it can be enough.

The easiest way to run this class is:

    include midonet::midonet_api

This call assumes that there is a zookeeper running in the target host and the
module will spawn a midonet\_api without keystone authentication.

This is a quite naive deployment, just for demo purposes. A more realistic one
would be:

    class {'midonet::midonet_api':
        zk_servers           =>  [{'ip'   => 'host1',
                             'port' => '2183'},
                            {'ip'   => 'host2'}],
        keystone_auth        => true,
        vtep                 => true,
        api_ip               => '92.234.12.4',
        keystone_host        => '92.234.12.9',
        keystone_port        => 35357  (35357 is already the default)
        keystone_admin_token => 'arrakis',
        keystone_tenant_name => 'other-than-services' ('services' by default)
    }

You can alternatively use the Hiera's yaml style:

    midonet::midonet_api::zk_servers:
        - ip: 'host1'
          port: 2183
        - ip: 'host2'
    midonet::midonet_api::vtep: true
    midonet::midonet_api::keystone_auth: true
    midonet::midonet_api::api_ip: '92.234.12.4'
    midonet::midonet_api::keystone_host: '92.234.12.9'
    midonet::midonet_api::keystone_port: 35357
    midonet::midonet_api::keystone_admin_token: 'arrakis'
    midonet::midonet_api::keystone_tenant_name: 'other-than-services'

Please note that Zookeeper port is not mandatory and defaulted to 2181.

#### Midonet CLI

Install the MidonetCLI this way:

    include midonet::midonet_cli

Module does not configure the ~/.midonetrc file that `python-midonetlcinet` needs to run right now. Please, check out how to configure the midonet client [here](http://docs.midonet.org/docs/latest/quick-start-guide/rhel-7_juno-rdo/content/_midonet_cli_installation.html)

#### Neutron Plugin

Install and configure Midonet Neutron Plugin. Please note that manifest does
install Neutron (because it is a requirement of 'python-neutron-plugin-midonet'
package) but it does not configure it nor run it. It just configure the specific
midonet plugin files. It is supposed to be deployed along any existing puppet
module that configures Neutron, such as [puppetlabs/neutron](https://forge.puppetlabs.com/puppetlabs/neutron/4.1.0)

The easiest way to run this class is:

    include midonet::neutron_plugin

Although it is quite useless: it assumes that there is a Neutron server already
configured and a MidoNet API running localhost with Mock authentication.

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

## Limitations

This module supports:

  * Ubuntu 14.04
  * Ubuntu 12.04
  * CentOS 6.6
  * CentOS 7

This module has been tested in Puppet 3.7.3 version, but we belive that it
should work without problems in any Puppet 3.x version.

## Development

We happily will accept patches and new ideas to improve this module. Clone
MidoNet's puppet repo in:

    git clone http://github.com/midonet/arrakis

and send patches via:

    git review

You can see the state of the patch in:

    https://review.gerrithub.io/#/q/status:open+project:midonet/arrakis

We are using a Gerrit's rebase-based branching policy. So please, submit a
single commit per change. If a commit has been rejected, do the changes you need
to do and squash your changes with the previous patch:

    git commit --amend

We are using kitchen (http://kitchen.ci) for integration testing and puppet-lint
for syntax code convention. To test the module before send a patch, execute:

    $ rake lint
    $ rake test

inside the `midonet-midonet` directory

## Release Notes

* v2015.1.0: Initial manifests
