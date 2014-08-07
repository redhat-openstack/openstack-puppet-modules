# = Class: uchiwa::repo::apt
#
# Adds the uchiwa repo to Apt
#
class uchiwa::repo::apt {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if defined(apt::source) and defined(apt::key) {

    $ensure = $uchiwa::install_repo ? {
      true    => 'present',
      default => 'absent'
    }

    if $uchiwa::repo_source {
      $url = $uchiwa::repo_source
    } else {
      $url = 'http://repos.sensuapp.org/apt'
    }

    if $ensure == 'present' {
      apt::key { 'sensu':
        key         => $uchiwa::repo_key_id,
        key_source  => $uchiwa::repo_key_source,
      }
    }
    apt::source { 'sensu':
      ensure      => $ensure,
      location    => $url,
      release     => 'sensu',
      repos       => $uchiwa::repo,
      include_src => false,
      before      => Package['uchiwa'],
    }

  } else {
    fail('This class requires puppet-apt module')
  }

}
