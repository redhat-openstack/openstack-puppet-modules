class pacemaker::install (
  $ensure = present,
) {
  include pacemaker::params
  package { $pacemaker::params::package_list:
    ensure => $ensure,
  }
}
