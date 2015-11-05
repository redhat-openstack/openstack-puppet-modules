# Change log

## 1.0.9 (unreleased)

* TBD


## 1.0.8 (October 16, 2014)

IMPROVEMENTS

* bootstrap: Use new GitHub.com URL for retrieving raw user content.
* Data directory and data log directory are only created when needed. (thanks bazilek) [GH-3]

BUG FIXES

* Fix and improve ZK initialization, which also resolves
  [Wirbelsturm issue 25](https://github.com/miguno/wirbelsturm/issues/25).


## 1.0.7 (April 08, 2014)

IMPROVEMENTS

* Support the `$data_log_dir` parameter for setting ZooKeepers `dataLogDir` parameter.  This allows you to split the
  directory for transaction logs (`dataLogDir`) from the directory containing snapshot files (`dataDir`), which is the
  recommended production setup for ZooKeeper.
* Support the `$config_map` parameter.  This parameter (a Puppet hash) can be used to inject arbitrary key-value pairs
  into the ZooKeeper configuration file.
* The unused class parameters `$leader_election_port` and `$peer_port` were removed.

BACKWARDS INCOMPATIBILITY

* The following class parameters have been removed.  You should set those via the new `$config_map` parameter instead.
  Note: The new default ZK configuration (which makes use of a default value for `$config_map`) is equivalent to the
  previous default ZK configuration, i.e. settings such as `$autopurge_purge_interval` were moved to `$config_map`.
    * `$autopurge_purge_interval`
    * `$autopurge_snap_retain_count`
    * `$init_limit`
    * `$max_client_connections`
    * `$sync_limit`
    * `$tick_time`


## 1.0.6 (April 08, 2014)

IMPROVEMENTS

* Remove `puppetlabs/stdlib` from `Modulefile` to decouple us from PuppetForge.


## 1.0.5 (March 21, 2014)

IMPROVEMENTS

* Add `$user_manage` and `$group_manage` parameters.
* Initial support for testing this module.
    * A skeleton for acceptance testing (`rake acceptance`) was also added.  Acceptance tests do not work yet.

BACKWARDS INCOMPATIBILITY

* Change default value of `$package_ensure` from "latest" to "present".
* Puppet module fails if run on an unsupported platform.  Currently we only support the RHEL OS family.


## 1.0.4 (March 20, 2014)

* Only use x.y.z to specify versions because librarian-puppet is very picky, and seems not to fully comply to
  semantic versioning rules.


## 1.0.3+2 (March 20, 2014)

* Use semantic versioning, e.g. `1.0.3+1` instead of `1.0.3.1`.  Otherwise librarian-puppet will fail.


## 1.0.3.1 (March 20, 2014)

* Correctly bump version in `Modulefile` to 1.0.3.1.


## 1.0.3 (March 20, 2014)

GENERAL CHANGES

* Change stop signal of (supervised) zookeeper process from KILL to INT.

BUG FIXES

* GH-1: supervisord restart problems when zookeeper-server is killed


## 1.0.2 (March 11, 2014)

BUG FIXES

* Correctly create `$data_dir` recursively.  (Doh!)


## 1.0.1 (March 11, 2014)

IMPROVEMENTS

* Recursively create `$data_dir` if needed.


## 1.0.0 (February 25, 2014)

* Initial release.
