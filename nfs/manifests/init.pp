# == Class: nfs
#
# Manages NFS
#
class nfs (
  $hiera_hash  = false,
  $nfs_package = 'USE_DEFAULTS',
  $nfs_service = 'USE_DEFAULTS',
  $mounts      = undef,
) {

  if type($hiera_hash) == 'string' {
    $hiera_hash_real = str2bool($hiera_hash)
  } else {
    $hiera_hash_real = $hiera_hash
  }
  validate_bool($hiera_hash_real)

  case $::osfamily {
    'Debian': {

      include rpcbind

      $default_nfs_package = 'nfs-common'

      case $::lsbdistid {
        'Debian': {
          $default_nfs_service = 'nfs-common'
        }
        'Ubuntu': {
          $default_nfs_service = undef
        }
        default: {
          fail("nfs module only supports lsbdistid Debian and Ubuntu of osfamily Debian. Detected lsbdistid is <${::lsbdistid}>.")
        }
      }
    }
    'RedHat': {

      $default_nfs_package = 'nfs-utils'

      case $::lsbmajdistrelease {
        '5': {
          include nfs::idmap
          $default_nfs_service = 'nfs'
        }
        '6': {
          include rpcbind
          include nfs::idmap
          $default_nfs_service = 'nfs'
        }
        '7': {
          include rpcbind
          include nfs::idmap
          $default_nfs_service = undef
        }
        default: {
          fail("nfs module only supports EL 5, 6 and 7 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
    }
    'Solaris': {
      case $::kernelrelease {
        '5.10': {
          $default_nfs_package = [ 'SUNWnfsckr',
                                    'SUNWnfscr',
                                    'SUNWnfscu',
                                    'SUNWnfsskr',
                                    'SUNWnfssr',
                                    'SUNWnfssu',
          ]
        }
        '5.11': {
          $default_nfs_package = [ 'service/file-system/nfs',
                                    'system/file-system/nfs',
          ]
        }
        default: {
          fail("nfs module only supports Solaris 5.10 and 5.11 and kernelrelease was detected as <${::kernelrelease}>.")
        }
      }

      $default_nfs_service = 'nfs/client'
    }
    'Suse' : {

      include nfs::idmap
      $default_idmap_service = 'rpcidmapd'

      case $::lsbmajdistrelease {
        '10': {
          $default_nfs_package = 'nfs-utils'
          $default_nfs_service = 'nfs'
        }
        '11': {
          $default_nfs_package = 'nfs-client'
          $default_nfs_service = 'nfs'
        }
        default: {
          fail("nfs module only supports Suse 10 and 11 and lsbmajdistrelease was detected as <${::lsbmajdistrelease}>.")
        }
      }
    }

    default: {
      fail("nfs module only supports osfamilies Debian, RedHat, Solaris and Suse, and <${::osfamily}> was detected.")
    }
  }

  if $nfs_package == 'USE_DEFAULTS' {
    $nfs_package_real = $default_nfs_package
  } else {
    $nfs_package_real = $nfs_package
  }

  if $nfs_service == 'USE_DEFAULTS' {
    $nfs_service_real = $default_nfs_service
  } else {
    $nfs_service_real = $nfs_service
  }

  package { $nfs_package_real:
    ensure => present,
  }

  if $nfs_service_real {
    service { 'nfs_service':
      ensure    => running,
      name      => $nfs_service_real,
      enable    => true,
      subscribe => Package[$nfs_package_real],
    }
  }

  if $mounts != undef {

    if $hiera_hash_real == true {
      $mounts_real = hiera_hash('nfs::mounts')
    } else {
      $mounts_real = $mounts
      notice('Future versions of the nfs module will default nfs::hiera_hash to true')
    }

    validate_hash($mounts_real)
    create_resources('types::mount',$mounts_real)
  }
}
