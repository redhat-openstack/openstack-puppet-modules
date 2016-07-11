# == Class: pacemaker::contain
#
# Work around this bug https://github.com/puppetlabs/puppet/pull/2633
# in puppet where contains cannot have a absolute class as a
# parameter.  It has not been fixed for 3.6 which is tested in the CI.
#
# === Parameters
#
# [*class_name*]
#  The relative name of the class to contain.
#  Default to $name
define pacemaker::contain ($class_name='') {
  $k = pick($class_name, $name)
  validate_re($k, '^[^:][^:]', "The class name must be relative not ${k}")
  include "::${k}"
  # lint:ignore:relative_classname_inclusion
  contain $k
  # lint:endignore
}
