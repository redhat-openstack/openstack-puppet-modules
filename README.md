# OpenStack Puppet Modules

This repository contains a collection of
[Puppet](http://puppetlabs.com/puppet/puppet-open-source) modules shared between
several OpenStack installers, including:
* [Packstack](https://github.com/stackforge/packstack)
* [RDOManager](https://www.rdoproject.org/rdo-manager/) (upstream for OSPd)
* [OpenStack Foreman Installer](http://github,com/redhat-openstack/astapor/) (no
  longer actively developed)

These modules are included via git subtrees, which reference the various upstream
modules at a given revision, which can be found in the [Puppetfile](Puppetfile), and is
not really meant to be used directly, but rather to be utilized by a composition
layer, such as the above installers.  We use
[gerrithub](https://review.gerrithub.io/#/q/project:redhat-openstack/openstack-puppet-modules)
for reviews, please see the [Contributing](CONTRIBUTING.md) document for more detail on the
process.

The repository contains branches which map to OpenStack releases, as well as
branches that are basically upstream plus any required patches that have not yet
been merged (or can not be merged for some reason), but are needed by one or
more of the target installers in order for that installer to work properly.
This is a constantly moving target, and the goal is to eliminate as many of this
kind of patch as possible, with each release attempting to contain less of
these than the previous one.

The various releases map like this:

OPM Branch       | Openstack Release
---------------- | ------------------
kilo             | upstream kilo
f23-patches      | kilo + patches
upstream-liberty | upstream liberty
stable/liberty   | liberty + patches
upstream-master  | upstream master
stable/master    | master + patches

Each time a change is pushed to a {version} + patches branch, and automated
build system generates rpms.  These can be found in the follow places:
* [kilo](http://trunk.rdoproject.org/centos7-kilo/report.html)
* [liberty](http://trunk.rdoproject.org/centos7-liberty/report.html)
* [master](http://trunk.rdoproject.org/centos7/report.html)

Please see [Building.md](BUILDING.md) for more information on how this process works up to
the point that the automation takes over.
