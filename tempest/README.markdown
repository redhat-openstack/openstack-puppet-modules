Tempest
=======

5.0.0 - 2014.2.0 - Juno

Module for installing and configuring tempest.

Tempest is the test suite that can be used to run integration
tests on an installed openstack environment.

This module assumes the provisioning of the initial OpenStack
resources has been done beforehand.

Release Notes
-------------

** 5.0.0 **

* Stable Juno release
* Pinned vcsrepo dependency to 2.x
* Bumped stdlib dependency to 4.x
* Added ability to hide secrets from puppet logs
* Removed orphaned os_concat function
* Removed dependencies on mysql and postgresql devel libraries
