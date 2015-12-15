# == Class: swift::params
#
class swift::params {
  case $::osfamily {
    'Debian': {
      $package_name                      = 'swift'
      $client_package                    = 'python-swiftclient'
      $proxy_package_name                = 'swift-proxy'
      $proxy_server_service_name         = 'swift-proxy'
      $object_package_name               = 'swift-object'
      $object_server_service_name        = 'swift-object'
      $object_auditor_service_name       = 'swift-object-auditor'
      $object_replicator_service_name    = 'swift-object-replicator'
      $object_updater_service_name       = 'swift-object-updater'
      $object_expirer_package_name       = 'swift-object-expirer'
      $object_expirer_service_name       = 'swift-object-expirer'
      $container_package_name            = 'swift-container'
      $container_server_service_name     = 'swift-container'
      $container_auditor_service_name    = 'swift-container-auditor'
      $container_replicator_service_name = 'swift-container-replicator'
      $container_updater_service_name    = 'swift-container-updater'
      $container_sync_service_name       = 'swift-container-sync'
      $account_package_name              = 'swift-account'
      $account_server_service_name       = 'swift-account'
      $account_auditor_service_name      = 'swift-account-auditor'
      $account_reaper_service_name       = 'swift-account-reaper'
      $account_replicator_service_name   = 'swift-account-replicator'
      $swift3                            = 'swift-plugin-s3'
      if $::operatingsystem == 'Ubuntu' {
        $service_provider = 'upstart'
      } else {
        $service_provider = undef
      }
    }
    'RedHat': {
      $package_name                      = 'openstack-swift'
      $client_package                    = 'python-swiftclient'
      $proxy_package_name                = 'openstack-swift-proxy'
      $proxy_server_service_name         = 'openstack-swift-proxy'
      $object_package_name               = 'openstack-swift-object'
      $object_server_service_name        = 'openstack-swift-object'
      $object_auditor_service_name       = 'openstack-swift-object-auditor'
      $object_replicator_service_name    = 'openstack-swift-object-replicator'
      $object_updater_service_name       = 'openstack-swift-object-updater'
      $object_expirer_package_name       = 'openstack-swift-proxy'
      $object_expirer_service_name       = 'openstack-swift-object-expirer'
      $container_package_name            = 'openstack-swift-container'
      $container_server_service_name     = 'openstack-swift-container'
      $container_auditor_service_name    = 'openstack-swift-container-auditor'
      $container_replicator_service_name = 'openstack-swift-container-replicator'
      $container_updater_service_name    = 'openstack-swift-container-updater'
      $container_sync_service_name       = 'openstack-swift-container-sync'
      $account_package_name              = 'openstack-swift-account'
      $account_server_service_name       = 'openstack-swift-account'
      $account_auditor_service_name      = 'openstack-swift-account-auditor'
      $account_reaper_service_name       = 'openstack-swift-account-reaper'
      $account_replicator_service_name   = 'openstack-swift-account-replicator'
      $service_provider                  = undef
      $swift3                            = 'openstack-swift-plugin-swift3'
    }
    default: {
        fail("Unsupported osfamily: ${::osfamily} for os ${::operatingsystem}")
    }
  }
  $swift_init_service_names = [
    'swift-proxy-server',
    'swift-object-auditor',
    'swift-object-expirer',
    'swift-object-replicator',
    'swift-object-server',
    'swift-object-updater',
    'swift-account-auditor',
    'swift-account-reaper',
    'swift-account-replicator',
    'swift-account-server',
    'swift-container-auditor',
    'swift-container-replicator',
    'swift-container-server',
    'swift-container-sync',
    'swift-container-updater',
  ]
}
