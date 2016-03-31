## 8.0.0 and beyond

From 8.0.0 release and beyond, release notes are published on
[docs.openstack.org](http://docs.openstack.org/releasenotes/puppet-manila/).

##2015-11-25 - 7.0.0
###Summary

This is a backwards-incompatible major release for OpenStack Liberty.

####Backwards-incompatible changes
- rabbitmq: do not manage rabbitmq service anymore
- move qpid settings to oslo_messaging_qpid section

####Features
- keystone/auth: make service description configurable
- add related parameters to manila::quota
- add tag to package and service resources
- add support to configure GlusterFS drivers with Manila shares
- reflect provider change in puppet-openstacklib
- put all the logging related parameters to the logging class
- simplify rpc_backend parameter
- add options to enable Manila to run with NFS-Ganesha backend
- introduce manila::db class
- db: Use postgresql lib class for psycopg package
- add related parameters to oslo_messaging_amqp section

####Bugfixes
- rely on autorequire for config resource ordering
- api: require ::keystone::python

####Maintenance
- acceptance: enable debug & verbosity for OpenStack logs
- initial msync run for all Puppet OpenStack modules
- fix rspec 3.x syntax
- try to use zuul-cloner to prepare fixtures
- remove class_parameter_defaults puppet-lint check
- acceptance: use common bits from puppet-openstack-integration

##2015-10-10 - 6.1.0
### Summary

This is a maintenance release in the Kilo series.

####Maintenance
- acceptance: checkout stable/kilo puppet modules

##2015-07-08 - 6.0.0
###Summary

- Initial release of the puppet-manila module
