# puppet-zookeeper [![Build Status](https://travis-ci.org/miguno/puppet-zookeeper.png?branch=master)](https://travis-ci.org/miguno/puppet-zookeeper)

[Wirbelsturm](https://github.com/miguno/wirbelsturm)-compatible [Puppet](http://puppetlabs.com/) module to deploy
[ZooKeeper](http://zookeeper.apache.org/) servers.

You can use this Puppet module to deploy ZooKeeper to physical and virtual machines, for instance via your existing
internal or cloud-based Puppet infrastructure and via a tool such as [Vagrant](http://www.vagrantup.com/) for local
and remote deployments.

---

Table of Contents

* <a href="#quickstart">Quick start</a>
* <a href="#features">Features</a>
* <a href="#requirements">Requirements and assumptions</a>
* <a href="#installation">Installation</a>
* <a href="#configuration">Configuration</a>
* <a href="#usage">Usage</a>
    * <a href="#configuration-examples">Configuration examples</a>
        * <a href="#hiera">Using Hiera</a>
        * <a href="#manifests">Using Puppet manifests</a>
    * <a href="#service-management">Service management</a>
    * <a href="#log-files">Log files</a>
* <a href="#known-issues">Known issues and limitations</a>
* <a href="#todo">TODO</a>
* <a href="#changelog">Change log</a>
* <a href="#contributing">Contributing</a>
* <a href="#license">License</a>

---

<a name="quickstart"></a>

# Quick start

See section [Usage](#usage) below.


<a name="features"></a>

# Features

* Supports ZooKeeper 3.4.5+.  May work with earlier versions, too.
* Decouples code (Puppet manifests) from configuration data ([Hiera](http://docs.puppetlabs.com/hiera/1/)) through the
  use of Puppet parameterized classes, i.e. class parameters.  Hence you should use Hiera to control how ZooKeeper is
  deployed and to which machines.
* Supports RHEL OS family (e.g. RHEL 6, CentOS 6, Amazon Linux).
    * Code contributions to support additional OS families are welcome!
* Supports deployment of standalone ZooKeeper setups (1 node) as well as ZooKeeper quorums (3+ nodes).
* ZooKeeper is run under process supervision via [supervisord](http://www.supervisord.org/) version 3.0+.


<a name="requirements"></a>

# Requirements and assumptions

* This module requires that the target machines to which you are deploying ZooKeeper have **yum repositories**
  **configured** for pulling the ZooKeeper package (i.e. RPM).
    * One option is to use the ZooKeeper RPM provided by Cloudera.  See
      [cloudera-cdh4.repo](http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/cloudera-cdh4.repo).
* This module requires that the target machines have a **Java JRE/JDK installed** (e.g. via a separate Puppet module
  such as [puppetlabs-java](https://github.com/puppetlabs/puppetlabs-java)).  You may also want to make sure that the
  Java package is installed _before_ ZooKeeper to prevent startup problems.
    * Because different teams may have different approaches to install "base" packages such as Java, this module does
      intentionally not puppet-require Java directly.
* This module requires the following **additional Puppet modules**:

    * [puppetlabs/stdlib](https://github.com/puppetlabs/puppetlabs-stdlib)
    * [puppet-supervisor](https://github.com/miguno/puppet-supervisor)

  It is recommended that you add these modules to your Puppet setup via
  [librarian-puppet](https://github.com/rodjek/librarian-puppet).  See the `Puppetfile` snippet in section
  _Installation_ below for a starting example.
* **When using Vagrant**: Depending on your Vagrant box (image) you may need to manually configure/disable firewall
  settings -- otherwise machines may not be able to talk to each other.  One option to manage firewall settings is via
  [puppetlabs-firewall](https://github.com/puppetlabs/puppetlabs-firewall).


<a name="installation"></a>

# Installation

It is recommended to use [librarian-puppet](https://github.com/rodjek/librarian-puppet) to add this module to your
Puppet setup.

Add the following lines to your `Puppetfile`:

```
# Add the stdlib dependency as hosted on public Puppet Forge.
#
# We intentionally do not include the stdlib dependency in our Modulefile to make it easier for users who decided to
# use internal copies of stdlib so that their deployments are not coupled to the availability of PuppetForge.  While
# there are tools such as puppet-library for hosting internal forges or for proxying to the public forge, not everyone
# is actually using those tools.
mod 'puppetlabs/stdlib'

# Add the puppet-zookeeper module
mod 'zookeeper',
  :git => 'https://github.com/miguno/puppet-zookeeper.git'

# Add the puppet-supervisor module dependency
mod 'supervisor',
  :git => 'https://github.com/miguno/puppet-supervisor.git'
```

Then use librarian-puppet to install (or update) the Puppet modules.


<a name="configuration"></a>

# Configuration

* See [init.pp](manifests/init.pp) for the list of currently supported configuration parameters.  These should be
  self-explanatory.
* See [params.pp](manifests/params.pp) for the default values of those configuration parameters.

Of special note is the class parameter `$config_map`:  You can use this parameter to "inject" arbitrary ZooKeeper
config settings via Hiera/YAML into the ZooKeeper configuration file (default name: `zoo.cfg`).  However you should not
re-define config settings via `$config_map` that already have explicit Puppet class parameters (such as `$data_dir`,
`$data_log_dir`, `$client_port`, `$myid`, `$quorum`).  See the examples below for more information on `$config_map`
usage.


<a name="usage"></a>

# Usage

**IMPORTANT: Make sure you read and follow the [Requirements and assumptions](#requirements) section above.**
**Otherwise the examples below will of course not work.**


<a name="configuration-examples"></a>

## Configuration examples


<a name="hiera"></a>

### Using Hiera

Simple example, using default settings.  This will start a ZooKeeper server that listens on port `2181/tcp`.

```yaml
---
classes:
  - supervisor
  - zookeeper::service
```

A more sophisticated example that overrides some of the default settings and also demonstrates the use of `$config_map`.
The snippet below also includes a (disabled) example for configuring ZooKeeper quorums.

```yaml
---
classes:
  - supervisor
  - zookeeper::service

## Supervisord
supervisor::logfile_maxbytes: '20MB'
supervisor::logfile_backups: 5

## ZooKeeper
zookeeper::myid: 1
zookeeper::config_map:
  autopurge.purgeInterval: 48
  autopurge.snapRetainCount: 3
  initLimit: 15
  maxClientCnxns: 500
  syncLimit: 3
  tickTime: 3000

## If you want to use a quorum (of usually 3 or 5 ZooKeeper servers), use a configuration similar
## to the following.  Make sure to set 'zookeeper::myid' appropriately for the machines in the
## quorum (myid must match 'server.X').
##
#zookeeper::quorum:
#  - 'server.1=zookeeper1:2888:3888'
#  - 'server.2=zookeeper2:2888:3888'
#  - 'server.3=zookeeper3:2888:3888'
```


<a name="manifests"></a>

### Using Puppet manifests

_Note: It is recommended to use Hiera to control deployments instead of using this module in your Puppet manifests_
_directly._

TBD


<a name="service-management"></a>

## Service management

To manually start, stop, restart, or check the status of the ZooKeeper service, respectively:

    $ sudo supervisorctl [start|stop|restart|status] zookeeper

Example:

    $ sudo supervisorctl status zookeeper
    zookeeper                        RUNNING    pid 16461, uptime 2 days, 22:41:21

You can also use ZooKeeper's [Four Letter Words](http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_zkCommands)
to interact with ZooKeeper.

    # Example: Ask ZooKeeper "Are you ok?"
    $ echo ruok | nc <zookeeper-ip> 2181
    imok

_Note: A response of "imok" does not necessarily indicate that the server has joined the quorum, just that the server_
_process is active and bound to the specified client port. Use "stat" for details on state wrt quorum and client_
_connection information._


<a name="log-files"></a>

## Log files

_Note: The locations below may be different depending on the ZooKeeper RPM you are actually using._

* ZooKeeper log file: `/var/log/zookeeper/zookeeper.log`
* Supervisord log files related to ZooKeeper processes:
    * `/var/log/supervisor/zookeeper/zookeeper.out`
    * `/var/log/supervisor/zookeeper/zookeeper.err`
* Supervisord main log file: `/var/log/supervisor/supervisord.log`


<a name="known-issues"></a>

# Known issues and limitations

## ZooKeeper configuration for `dataDir` and `dataLogDir`

ZooKeeper requires the initialization of both `dataDir` (`$data_dir` class parameter) and `dataLogDir` (`$data_log_dir`
class parameter).  However the initialization script shipped with ZooKeeper only allows you to initialize both at the
same time, and it will fail/exit whenever one (or both) of them are already initialized.  Unfortunately, this behavior
of ZooKeeper means that you will not be easily able to change from an existing dataDir-only deployment to a setup that
splits dataDir and dataLogDir -- doing so requires manual intervention.  Of course if you create a ZooKeeper machine
from scratch than both variants (dataDir-only and dataDir+dataLogDir setups) will work out of the box.


<a name="todo"></a>

# TODO

* Enhance in-line documentation of Puppet manifests.
* Add more unit tests and specs.
* Add rollback/remove functionality to completely purge ZooKeeper related packages and configuration files from a
  machine.


<a name="changelog"></a>

## Change log

See [CHANGELOG](CHANGELOG.md).


<a name="contributing"></a>

## Contributing to puppet-zookeeper

Code contributions, bug reports, feature requests etc. are all welcome.

If you are new to GitHub please read [Contributing to a project](https://help.github.com/articles/fork-a-repo) for how
to send patches and pull requests to puppet-zookeeper.


<a name="license"></a>

## License

Copyright © 2014 Michael G. Noll

See [LICENSE](LICENSE) for licensing information.
