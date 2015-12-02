# = Class: uchiwa::repo::yum
#
# Adds the uchiwa YUM repo support
#
class uchiwa::repo::yum {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $uchiwa::install_repo  {
    if $uchiwa::repo_source {
      $url = $uchiwa::repo_source
    } else {
      $url = $uchiwa::repo ? {
        'unstable'  => "http://repos.sensuapp.org/yum-unstable/el/${::operatingsystemmajrelease}/\$basearch/",
        default     => "http://repos.sensuapp.org/yum/el/${::operatingsystemmajrelease}/\$basearch/"
      }
    }

    yumrepo { 'sensu':
      enabled  => 1,
      baseurl  => $url,
      gpgcheck => 0,
      name     => 'sensu',
      descr    => 'sensuapp.org uchiwa repo',
      before   => Package['uchiwa'],
    }
  }

}