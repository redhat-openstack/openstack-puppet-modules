##2014-10-24 - Features release 2.2.0
###Summary
* Sensu as first implementation of monitoring system
* Glance now supports NFS image storage backend
* Cinder now supports EMC VNX & iSCSI volume backends
* Nova now supports NFS instance storage backend
* Neutron now supports Cisco plugins with N1KV hardware (experimental)
* RabbitMQ can now be load-balanced by HAproxy
* Keystone roles for Heat are now created automatically
* Support for keepalived authentification
* MongoDB replicaset is now an option, so MongoDB can be standalone
* MySQL Galera has been tweaked to have better performances at scale
* Nova configuration has been tweaked to use read-only database feature and have better performances at scale
* Trove has been disabled by default since it's still in experimental status
* HAproxy: Allow user to bind multiple public/private IPs
* keepalived: allow vrrp traffic on a dedicated interface
* When running KVM, we check if VTX is really enabled
* HAproxy checks have been improve for OpenStack services
* Neutron: allow to specify tunnel type (i.e. VXLAN)
* Horizon: ALLOWED_HOST can now be controlled by the module
* Horizon: Allow user to speficy broader apache vhost settings
* Nova/RBD: support for RHEL 7

####Bugfixes
* Fix correct Puppet Ceph dependencies which could lead to bootstrap issues
* Fix issues with instance live migration support (nova configuration)
* Fix HAproxy checks for Spice (TCP instead of HTTP)

####Known Bugs
* No known bugs

##2014-07-15 - Features release 2.1.0
###Summary
* Advanced logging support with kibana3, elasticsearch and fluentd
* Improve SSL termination support
* File backend support for Glance
* OpenStack Database as a Service support (Trove) as experimental
* Pacemaker support in Red-Hat
* heat-engine is no more managed as a single point of failure

####Bugfixes
* Fix heat-cfn & heat-cloudwatch HAproxy binding
* Fix issues when using SSL termination

####Known Bugs
* No known bugs

##2014-06-19 - Features release 2.0.0
###Summary
* Icehouse release support
* OpenStack Object Storage support (Swift)
* Neutron Metadata multi-worker
* RBD flexibility on compute nodes
* Keystone and Nova v3 API support
* SSL termination support

####Bugfixes
* Fix nova-compute service when using RBD backend
* Fix cinder-volume service when creating a volume type
* Enable to have Swift Storage & Ceph OSD on same nodes

####Known Bugs
* No known bugs

##2014-05-06 - Features release 1.3.0
###Summary
* High Availability refactorization
* OpenStack services separation in different classes
* DHCP Agent: Add support of DNS server declaration
* Defaults values for all puppet parameters, can now support Hiera.
* Fix all unit tests to pass Travis

####Bugfixes
* Fix HAproxy configuration for Heat API binding

####Known Bugs
* When using RBD as Nova Backend, nova-compute should be notified
* When creating a volume type, cinder-volume should be notified
* Impossible to attach a volume backend by RBD if not using RBD backend for Nova

##2014-04-22 - Features release 1.2.0
###Summary
* Now supports Ubuntu 12.04
* Now supports Now supports Red Hat OpenStack Platform 4
* Can be deployed on 3 nodes
* Add cluster note type support for RabbitMQ configuration
* Block storage can now be backend by multiple RBD pools

####Bugfixes
* Fix a bug in Horizon in HTTP/HTTPS binding

####Known Bugs
* No known bugs

##2014-04-01 - Features release 1.1.0
###Summary
* Updated puppetlabs-rabbitmq to 3.1.0 (RabbitMQ to 3.2.4)
* Add Cinder Muli-backend support
* NetApp support for Cinder as a backend
* Keystone uses now MySQL for tokens storage (due to several issues with Memcache backend)
* Back to upstream puppet-horizon from stackforge
* Servername parameter support in Horizon configuration to allow SSL redirections
* puppet-openstack-cloud module QA is done by Travis
* network: add dhcp\_lease\_duration parameter support

####Bugfixes
* neutron: increase agent polling interval

####Known Bugs
* Bug in Horizon in HTTP/HTTPS binding (fixed in 1.2.0)

##2014-03-13 - First stable version 1.0.0
###Summary
* First stable version.

####Bugfixes
* No

####Known Bugs
* No known bugs
