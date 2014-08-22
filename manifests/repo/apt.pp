# = Class: uchiwa::repo::apt
#
# Adds the uchiwa repo to Apt
#
class uchiwa::repo::apt {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $uchiwa::install_repo {
    if defined(apt::source)  {

      $ensure = $uchiwa::install_repo ? {
        true    => 'present',
        default => 'absent'
      }

      if $uchiwa::repo_source {
        $url = $uchiwa::repo_source
      } else {
        $url = 'http://repos.sensuapp.org/apt'
      }

      apt::source { 'sensu':
        ensure      => $ensure,
        location    => $url,
        release     => 'sensu',
        repos       => $uchiwa::repo,
        include_src => false,
        key         => $uchiwa::repo_key_id,
        key_source  => $uchiwa::repo_key_source,
        before      => Package['uchiwa'],
      }

    } else {
      fail('This class requires puppet-apt module')
    }
  }
}
