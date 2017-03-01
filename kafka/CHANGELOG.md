##2014-10-10 - Release 1.0.0
###Summary

This release adds a number of new features and fixes lots of idempotency issues.
The main additions with this release are support for installing and configuring consumers, producers and mirrors

####Features

- added support for adding topics
- added support for managing consumers, producers, and mirrors
- improved documentation
- improved testing

####Bugfixes

- updated install_dir to /opt
- fixing install_dir symlink
- fixing idempotency issue in kafka server.properties
- fixing idempotency issue with untar-ing kafka package
- fixing bug in service restart

##2014-06-02 - Release 0.2.1
###Summary

  This is a bugfix release to fix conflict with wget dependency

####Bugfixes

 - Fixing conflict with maestrodev/wget in how it is installed causing issue with duplicate resource.

##2014-06-02 - Release 0.2.0
###Summary

  This release fixed some bugs with the kafka service and refactored the code in preparation of supporting things other than the broker.

####Features
 - refactoring of the kafka installation

####Bugfixes
 - fixing issue with kafka service not starting correctly.

##2014-05-27 - Release 0.1.0
###Summary

  Initial release. Support for the installation and configuration of a kafka broker
