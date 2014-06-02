# == Class kafka::broker::install
#
# This private class installs a kafka broker package and it's dependencies
#
class kafka::broker::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  class { '::kafka':
    version       => $kafka::broker::version,
    scala_version => $kafka::broker::scala_version,
    install_dir   => $kafka::broker::install_dir,
    mirror_url    => $kafka::broker::mirror_url,
    install_java  => $kafka::broker::install_java,
    package_dir   => $kafka::broker::package_dir
  }
}
