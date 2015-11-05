# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::broker::install
#
# This private class is meant to be called from `kafka::broker`.
# It downloads the package and installs it.
#
class kafka::broker::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if !defined(Class['::kafka']) {
    class { '::kafka':
      version       => $kafka::broker::version,
      scala_version => $kafka::broker::scala_version,
      install_dir   => $kafka::broker::install_dir,
      mirror_url    => $kafka::broker::mirror_url,
      install_java  => $kafka::broker::install_java,
      package_dir   => $kafka::broker::package_dir
    }
  }
}
