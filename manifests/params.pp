# == Class uchiwa::params
#
# This class is meant to be called from uchiwa
# It sets variables according to platform
#
class uchiwa::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'uchiwa'
      $service_name = 'uchiwa'
    }
    'RedHat', 'Amazon': {
      $package_name = 'uchiwa'
      $service_name = 'uchiwa'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $version         = 'latest'
  $install_repo    = true
  $repo            = 'main'
  $repo_source     = undef
  $repo_key_id     = '7580C77F'
  $repo_key_source = 'http://repos.sensuapp.org/apt/pubkey.gpg'
  $manage_services = true
  $manage_user     = true

  $sensu_api_endpoints  = [{
                            name     =>  'sensu',
                            ssl      =>  false,
                            insecure =>  false,
                            port     =>  4567,
                            user     =>  'sensu',
                            pass     =>  'sensu',
                            path     =>  '',
                            timeout  =>  5,
                          }]

  $host            =     '0.0.0.0'
  $port            =     3000
  $user            =     ''
  $pass            =     ''
  $refresh         =     5
}
