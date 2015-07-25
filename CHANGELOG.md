##2015-07-25 - Release 1.0.0
* Changed the default installation from Cassandra 2.1 to 2.2.
* Fixed a bug that arose when the cassandra config_path was set.
* Created a workaround for PUP-3829.
* Minor changes to the API (see the Upgrading section of the README).
* Allow a basic installation of OpsCenter.

##2015-07-18 - Release 0.4.3
* Module dependancy metadata was too strict.

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
