# Change Log for Puppet Module locp-cassandra

##2015-11-09 - Release 1.9.1 ([diff](https://github.com/locp/cassandra/compare/1.9.0...1.9.1))

### Summary

A bug fix release.

### Features

* N/A

### Bugfixes

* The default value for the permissions mode of the Cassandra configuration
  file were far too open.  Changed from 0666 to 0644.

### Improvements

* N/A

##2015-10-25 - Release 1.9.0 ([diff](https://github.com/locp/cassandra/compare/1.8.1...1.9.0))

### Summary

Added more features for the configuration of Cassandra, some improvements to
the testing carried out before a release and a minor correction to the
change log documentation.

### Features

* The following parameters have been added to the ::cassandra class to be
  configured into the configuration file:

  * client_encryption_algorithm
  * client_encryption_cipher_suites
  * client_encryption_protocol
  * client_encryption_require_client_auth
  * client_encryption_store_type
  * client_encryption_truststore
  * client_encryption_truststore_password
  * counter_cache_size_in_mb
  * index_summary_capacity_in_mb
  * key_cache_save_period
  * key_cache_keys_to_save
  * seed_provider_class_name
  * server_encryption_algorithm
  * server_encryption_cipher_suites
  * server_encryption_protocol
  * server_encryption_require_client_auth
  * server_encryption_store_type

  Please see the README file for more details.

### Bugfixes

* Corrected an incorrect date (typo) in this document.

### Improvements

* There is now an automated test to mitigate the risk of unnecessarily
  refreshes of the Cassandra service due to non-functional changes to the
  configuration file.

##2015-10-14 - Release 1.8.1 ([diff](https://github.com/locp/cassandra/compare/1.8.0...1.8.1))

### Summary

A minor bug fix.

### Features

* N/A

### Bugfixes

* Fixed an edge case issue concerning users that may have been using the
  fail_on_non_supported_os before it was fixed in 1.8.0.

### Improvements

* N/A

##2015-10-06 - Release 1.8.0 ([diff](https://github.com/locp/cassandra/compare/1.7.1...1.8.0))

### Summary

Some new features a minor bug fix and some non-functional improvements.

### Features

* Added the service_refresh and config_file_mode parameters to the Cassandra
  class.

### Bugfixes

* The name of the fail_on_non_supported_os parameter has been corrected.

### Improvements

* Automated acceptance tests in preparation for a release now run faster.

##1015-10-01 - Release 1.7.1 ([diff](https://github.com/locp/cassandra/compare/1.7.0...1.7.1))

### Summary

A minor bug fix that incorrctly gave a failed build status for the module.

### Features

* N/A

### Bugfixes

* Fixed a problem that was showing the status of the module build as an
  error since the release of the fog-google gem version 0.1.1.

### Improvements

* N/A

##2015-10-01 - Release 1.7.0 ([diff](https://github.com/locp/cassandra/compare/1.6.0...1.7.0))

### Summary

* Corrected a bug in how commitlog_sync has handled by Cassandra.
* Some non-functional improvements
* Additional features for the cassandra::datastax_repo class.

### Features

* Added the commitlog_segment_size_in_mb parameter to the cassandra class.
* Added the following fields to the cassandra::datastax_repo class:

  * descr
  * key_id
  * key_url
  * pkg_url
  * release

  This should make the configuring of repositories more flexible.

### Bugfixes

* Fixed a bug in how the commitlog_sync and the parameters that are
  associated with it are handled

### Improvements

The following non-functional improvements were implemented:

* Added tags to the module metadata.
* Migrated the acceptance tests from Vagrant to Docker.  The associated
  improvements to performance means that more rigorous acceptance tests can
  be applied in a shorter time.  For the first time as well, they are
  visible on Travis.

##2015-09-23 - Release 1.6.0 ([diff](https://github.com/locp/cassandra/compare/1.5.0...1.6.0))

### Summary

More parameters for ::cassandra and ::cassandra::datastax_agent.  Also some
non-functional improvements in the automated unit tests.

### Features

* The JAVA_HOME can now be set for the datastax_agent (see the
  cassandra::datastax_agent => java_home parameter).
* The file mode for the directories can now be specified for the
  commitlog_directory, data_file_directories and the saved_caches_directory
  in the cassandra class.

### Bugfixes

* N/A

### Improvements

* Uncovered resources in the unit testing are now tested.

##2015-09-21 - Release 1.5.0 ([diff](https://github.com/locp/cassandra/compare/1.4.2...1.5.0))

### Summary

More parameters have been added that can be configured into the
cassandra.yaml file.

### Features

* The following parameters to the cassandra class can be configured into
  the cassandra configuration:
  * broadcast_address
  * broadcast_rpc_address
  * commitlog_sync
  * commitlog_sync_batch_window_in_ms
  * commitlog_total_space_in_mb
  * concurrent_compactors
  * counter_cache_keys_to_save
  * file_cache_size_in_mb
  * initial_token
  * inter_dc_stream_throughput_outbound_megabits_per_sec
  * internode_authenticator
  * internode_recv_buff_size_in_bytes
  * internode_send_buff_size_in_bytes
  * memory_allocator
  * memtable_cleanup_threshold
  * memtable_flush_writers
  * memtable_heap_space_in_mb
  * memtable_offheap_space_in_mb
  * native_transport_max_concurrent_connections
  * native_transport_max_concurrent_connections_per_ip
  * native_transport_max_frame_size_in_mb
  * native_transport_max_threads
  * permissions_update_interval_in_ms
  * phi_convict_threshold
  * request_scheduler_options_default_weight
  * request_scheduler_options_throttle_limit
  * row_cache_keys_to_save
  * rpc_max_threads
  * rpc_min_threads
  * rpc_recv_buff_size_in_bytes
  * rpc_send_buff_size_in_bytes
  * streaming_socket_timeout_in_ms
  * stream_throughput_outbound_megabits_per_sec

### Bugfixes

* N/A

### Improvements

* Clarity of changes per release in the change log (this document).

##2015-09-15 - Release 1.4.2 ([diff](https://github.com/locp/cassandra/compare/1.4.1...1.4.2))

### Summary

Fixed a problem identified whilst releasing 1.4.1 and a bug fixed by a
contributed pull request.

### Features

* n/a

### Bugfixes

* Fixed a problem with the acceptance tests.
* The datastax-agent service is restarted if the package is updated.

### Improvements

* n/a


##2015-09-15 - Release 1.4.1 ([diff](https://github.com/locp/cassandra/compare/1.4.0...1.4.1))

### Summary

This release fixes a minor bug (possibly better described as a typing mistake)
and makes some non-functional improvements.  It also allows the user to
override the default behaviour of failing on a non-supported operating system.

### Features

* A new flag called `fail_on_non_suppoted_os` has been added to the
  `cassandra` class and can be set to **false** so that an attempt can be
  made to use this module on an operating system that is not in the Debian
  or Red Hat families.

### Bugfixes

* Changed the default value for the `package_name` of the
  `cassandra::optutils` class from `'undef'` to *undef*.

### Improvements

* Clarified the expectations of submitted contributions.
* Unit test improvements.

##2015-09-10 - Release 1.4.0 ([diff](https://github.com/locp/cassandra/compare/1.3.7...1.4.0))

* Ensured that directories specified in the directory parameters
  are controlled with file resources.

* Added the following parameters to the cassandra.yml file:
  * batchlog_replay_throttle_in_kb
  * cas_contention_timeout_in_ms
  * column_index_size_in_kb
  * commit_failure_policy
  * compaction_throughput_mb_per_sec
  * counter_cache_save_period
  * counter_write_request_timeout_in_ms
  * cross_node_timeout
  * dynamic_snitch_badness_threshold
  * dynamic_snitch_reset_interval_in_ms
  * dynamic_snitch_update_interval_in_ms
  * hinted_handoff_throttle_in_kb
  * index_summary_resize_interval_in_minutes
  * inter_dc_tcp_nodelay
  * max_hints_delivery_threads
  * max_hint_window_in_ms
  * permissions_validity_in_ms
  * range_request_timeout_in_ms
  * read_request_timeout_in_ms
  * request_scheduler
  * request_timeout_in_ms
  * row_cache_save_period
  * row_cache_size_in_mb
  * sstable_preemptive_open_interval_in_mb
  * tombstone_failure_threshold
  * tombstone_warn_threshold
  * trickle_fsync
  * trickle_fsync_interval_in_kb
  * truncate_request_timeout_in_ms
  * write_request_timeout_in_ms

##2015-09-08 - Release 1.3.7 ([diff](https://github.com/locp/cassandra/compare/1.3.6...1.3.7))
* Made the auto_bootstrap parameter available.

##2015-09-03 - Release 1.3.6 ([diff](https://github.com/locp/cassandra/compare/1.3.5...1.3.6))
* Fixed a bug, now allowing the user to set the enabled state of the Cassandra
  service.
* More cleaning up of the README and more links in that file to allow
  faster navigation.
  
##2015-09-01 - Release 1.3.5 ([diff](https://github.com/locp/cassandra/compare/1.3.4...1.3.5))
* Fixed a bug, now  allowing the user to set the running state of the
  Cassandra service.
* More automated testing with spec tests.
* A refactoring of the README.

##2015-08-28 - Release 1.3.4 ([diff](https://github.com/locp/cassandra/compare/1.3.3...1.3.4))
* Minor corrections to the README.
* The addition of the storage_cassandra_seed_hosts parameter to
  cassandra::opscenter::cluster_name which is part of a bigger part of
  work but is urgently require by a client.

##2015-08-27 - Release 1.3.3 ([diff](https://github.com/locp/cassandra/compare/1.3.2...1.3.3))
* Corrected dependency version for puppetlabs-apt.

##2015-08-26 - Release 1.3.2 ([diff](https://github.com/locp/cassandra/compare/1.3.1...1.3.2))
* Fixed bug in cassandra::opscenter::cluster_name.
* Fixed code in cassandra::firewall_ports::rule to avoid deprecation
  warnings concerning the use of puppetlabs-firewall => port.
* Added more examples to the README

##2015-08-22 - Release 1.3.1 ([diff](https://github.com/locp/cassandra/compare/1.3.0...1.3.1))
This was mainly a non-functional change.  The biggest thing to say is that
Debian 7 is now supported.

##2015-08-19 - Release 1.3.0 ([diff](https://github.com/locp/cassandra/compare/1.2.0...1.3.0))
* Allow additional TCP ports to be specified for the host based firewall.
* Fixed a problem where the client subnets were ignored by the firewall.
* Added more automated testing.
* Continued work on an ongoing improvement of the documentation.
* Added the ability to set the DC and RACK in the snitch properties.

##2015-08-10 - Release 1.2.0 ([diff](https://github.com/locp/cassandra/compare/1.1.0...1.2.0))
* Added the installation of Java Native Access (JNA) to cassandra::java
* For DataStax Enterprise, allow the remote storage of metric data with
  cassandra::opscenter::cluster_name.

##2015-08-03 - Release 1.1.0 ([diff](https://github.com/locp/cassandra/compare/1.0.1...1.1.0))
* Provided the cassandra::firewall_ports class.
* All OpsCenter options are now configurable in opscenterd.conf.
* ssl_storage_port is now configurable.

##2015-07-27 - Release 1.0.1 ([diff](https://github.com/locp/cassandra/compare/1.0.0...1.0.1))
* Provided a workaround for
  [CASSANDRA-9822](https://issues.apache.org/jira/browse/CASSANDRA-9822).

##2015-07-25 - Release 1.0.0 ([diff](https://github.com/locp/cassandra/compare/0.4.3...1.0.0))
* Changed the default installation from Cassandra 2.1 to 2.2.
* Fixed a bug that arose when the cassandra config_path was set.
* Created a workaround for
  [PUP-3829](https://tickets.puppetlabs.com/browse/PUP-3829).
* Minor changes to the API (see the Upgrading section of the README).
* Allow a basic installation of OpsCenter.

##2015-07-18 - Release 0.4.3 ([diff](https://github.com/locp/cassandra/compare/0.4.2...0.4.3))
* Module dependency metadata was too strict.

##2015-07-16 - Release 0.4.2 ([diff](https://github.com/locp/cassandra/compare/0.4.1...0.4.2))

* Some minor documentation changes.
* Fixed a problem with the module metadata that caused Puppetfile issues.
* Integrated with Coveralls (https://coveralls.io/github/locp/cassandra).
* Removed the deprecated config and install classes.  These were private
  so there is no change to the API.

##2015-07-14 - Release 0.4.1 ([diff](https://github.com/locp/cassandra/compare/0.4.0...0.4.1))

* Fixed a resource ordering problem in the cassandra::datastax class.
* Tidied up the documentation a bit.
* Some refactoring of the spec tests.

##2015-07-12 - Release 0.4.0 ([diff](https://github.com/locp/cassandra/compare/0.3.0...0.4.0))
### Summary

* Some major changes to the API on how Java, the optional Cassandra tools and
  the DataStax agent are installed.  See the Upgrading section of the README
  file.
* Allowed the setting of the *stomp_interface* for the DataStax agent.
* Non-functionally, we have integrated with Travis CI (see
  https://travis-ci.org/locp/cassandra for details) and thanks to those guys
  for providing such a neat service.
* More spec tests.

##2015-06-27 - Release 0.3.0 ([diff](https://github.com/locp/cassandra/compare/0.2.2...0.3.0))
### Summary

* Slight changes to the API.  See the Upgrading section of the README file
  for full details.
* Allow for the installation of the DataStax Agent.
* Improved automated testing (and fixed some bugs along the way).
* Confirmed Ubuntu 12.04 works OK with this module.
* A Cassandra 1.X template has been provided.
* Some smarter handling of the differences between Ubuntu/Debian and RedHat
  derivatives.

##2015-06-17 - Release 0.2.2 ([diff](https://github.com/locp/cassandra/compare/0.2.1...0.2.2))
### Summary
A non-functional change to change the following:

* Split the single manifest into multiple files.
* Implement automated testing.
* Test on additional operating systems.

##2015-05-28 - Release 0.2.1 ([diff](https://github.com/locp/cassandra/compare/0.2.0...0.2.1))
### Summary
A non-functional change to fix puppet-lint problems identified by Puppet
Forge.

##2015-05-28 - Release 0.2.0 ([diff](https://github.com/locp/cassandra/compare/0.1.0...0.2.0))
### Summary
Added more parameters and improved the module metadata.

##2015-05-26 - Release 0.1.0
### Summary
An initial release with **VERY** limited options.
