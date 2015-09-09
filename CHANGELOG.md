# Change Log for Puppet Module locp-cassandra

##2015-09-08 - Release 1.3.7
* Made the auto_bootstrap parameter available.

##2015-09-03 - Release 1.3.6
* Fixed a bug, now allowing the user to set the enabled state of the Cassandra
  service.
* More cleaning up of the README and more links in that file to allow
  faster navigation.
  
##2015-09-01 - Release 1.3.5
* Fixed a bug, now  allowing the user to set the running state of the
  Cassandra service.
* More automated testing with spec tests.
* A refactoring of the README.

##2015-08-28 - Release 1.3.4
* Minor corrections to the README.
* The addtion of the storage_cassandra_seed_hosts parameter to
  cassandra::opscenter::cluster_name which is part of a bigger part of
  work but is urgently require by a client.

##2015-08-27 - Release 1.3.3
* Corrected dependency version for puppetlabs-apt.

##2015-08-26 - Release 1.3.2
* Fixed bug in cassandra::opscenter::cluster_name.
* Fixed code in cassandra::firewall_ports::rule to avoid deprecation
  warnings concerning the use of puppetlabs-firewall => port.
* Added more examples to the README

##2015-08-22 - Release 1.3.1
This was mainly a non-functional change.  The biggest thing to say is that
Debian 7 is now supported.

##2015-08-19 - Release 1.3.0
* Allow additional TCP ports to be specifed for the host based firewall.
* Fixed a problem where the client subnets were ignored by the firewall.
* Added more automated testing.
* Continued work on an ongoing improvement of the documentation.
* Added the ability to set the DC and RACK in the snitch properties.

##2015-08-10 - Release 1.2.0
* Added the installation of Java Native Access (JNA) to cassandra::java
* For DataStax Enterprise, allow the remote storage of metric data with
  cassandra::opscenter::cluster_name.

##2015-08-03 - Release 1.1.0
* Provided the cassandra::firewall_ports class.
* All OpsCenter options are now configurable in opscenterd.conf.
* ssl_storage_port is now configurable.

##2015-07-27 - Release 1.0.1
* Provided a workaround for
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).

##2015-07-25 - Release 1.0.0
* Changed the default installation from Cassandra 2.1 to 2.2.
* Fixed a bug that arose when the cassandra config_path was set.
* Created a workaround for
  [PUP-3829](https://tickets.puppetlabs.com/browse/PUP-3829).
* Minor changes to the API (see the Upgrading section of the README).
* Allow a basic installation of OpsCenter.

##2015-07-18 - Release 0.4.3
* Module dependency metadata was too strict.

##2015-07-16 - Release 0.4.2

* Some minor documentation changes.
* Fixed a problem with the module metadata that caused Puppetfile issues.
* Integrated with Coveralls (https://coveralls.io/github/locp/cassandra).
* Removed the deprecated config and install classes.  These were private
  so there is no change to the API.

##2015-07-14 - Release 0.4.1

* Fixed a resource ordering problem in the cassandra::datastax class.
* Tidied up the documentation a bit.
* Some refactoring of the spec tests.

##2015-07-12 - Release 0.4.0
### Summary

* Some major changes to the API on how Java, the optional Cassandra tools and
  the DataStax agent are installed.  See the Upgrading section of the README
  file.
* Allowed the setting of the *stomp_interface* for the DataStax agent.
* Non-functionally, we have integrated with Travis CI (see
  https://travis-ci.org/locp/cassandra for details) and thanks to those guys
  for providing such a neat service.
* More spec tests.

##2015-06-27 - Release 0.3.0
### Summary

* Slight changes to the API.  See the Upgrading section of the README file
  for full details.
* Allow for the installation of the DataStax Agent.
* Improved automated testing (and fixed some bugs along the way).
* Confirmed Ubuntu 12.04 works OK with this module.
* A Cassandra 1.X template has been provided.
* Some smarter handling of the differences between Ubuntu/Debian and RedHat
  derivatives.

##2015-06-17 - Release 0.2.2
### Summary
A non-functional change to change the following:

* Split the single manifest into multiple files.
* Implement automated testing.
* Test on additional operating systems.

##2015-05-28 - Release 0.2.1
### Summary
A non-functional change to fix puppet-lint problems identified by Puppet
Forge.

##2015-05-28 - Release 0.2.0
### Summary
Added more parameters and improved the module metadata.

##2015-05-26 - Release 0.1.0
### Summary
An initial release with **VERY** limited options.
