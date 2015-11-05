# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class: kafka::consumer::install
#
# This private class is meant to be called from `kafka::consumer`.
# It downloads the package and installs it.
#
class kafka::consumer::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if !defined(Class['::kafka']) {
    class { '::kafka':
      version       => $kafka::consumer::version,
      scala_version => $kafka::consumer::scala_version,
      install_dir   => $kafka::consumer::install_dir,
      mirror_url    => $kafka::consumer::mirror_url,
      install_java  => $kafka::consumer::install_java,
      package_dir   => $kafka::consumer::package_dir
    }
  }
}
