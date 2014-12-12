# == Define: common::remove_if_empty
#
# Removes a file if it exists and is empty.
#
# Example usage:
#
#  common::remove_if_empty { '/path/to/potentially_empty_file': }
#
define common::remove_if_empty () {

  validate_absolute_path($name)

  exec { "remove_if_empty-${name}":
    command => "rm -f ${name}",
    unless  => "test -f ${name}; if [ $? == '0' ]; then test -s ${name}; fi",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
  }
}
