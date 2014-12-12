# == Class: nfs::idmap
#
# Manages idmapd
#
class nfs::idmap (
  $idmap_package             = 'USE_DEFAULTS',
  $idmapd_conf_path          = '/etc/idmapd.conf',
  $idmapd_conf_owner         = 'root',
  $idmapd_conf_group         = 'root',
  $idmapd_conf_mode          = '0644',
  $idmapd_service_name       = 'USE_DEFAULTS',
  $idmapd_service_enable     = true,
  $idmapd_service_hasstatus  = true,
  $idmapd_service_hasrestart = true,
  # idmapd.conf options
  $idmap_domain              = $::domain,
  $ldap_server               = 'UNSET',
  $ldap_base                 = 'UNSET',
  $local_realms              = $::domain,
  $translation_method        = 'nsswitch',
  $nobody_user               = 'nobody',
  $nobody_group              = 'nobody',
  $verbosity                 = '0',
  $pipefs_directory          = 'USE_DEFAULTS',
) {

  $is_idmap_domain_valid = is_domain_name($idmap_domain)
  if $is_idmap_domain_valid != true {
    fail("nfs::idmap::idmap_domain parameter, <${idmap_domain}>, is not a valid name.")
  }

  $is_ldap_server_valid = is_domain_name($ldap_server)
  if $is_ldap_server_valid != true {
    fail("nfs::idmap::ldap_server parameter, <${ldap_server}>, is not a valid name.")
  }
  validate_re($verbosity, '^(\d+)$', "verbosity parameter, <${verbosity}>, does not match regex.")

  $ldap_base_type = type($ldap_base)

  case $ldap_base_type {
    'String': {
      $ldap_base_real = $ldap_base
    }
    'Array': {
      $ldap_base_real = inline_template('<%= ldap_base.join(\',\') %>')
    }
    default: {
      fail("valid types for ldap_base are String and Array. Detected type is <${ldap_base_type}>")
    }
  }

  $local_realms_type = type($local_realms)

  case $local_realms_type {
    'String': {
      $local_realms_real = $local_realms
    }
    'Array': {
      $local_realms_real = inline_template('<%= local_realms.join(\',\') %>')
    }
    default: {
      fail("valid types for local_realms are String and Array. Detected type is <${local_realms_type}>")
    }
  }

  $translation_method_type = type($translation_method)

  case $translation_method_type {
    'String': {
      $translation_method_real = $translation_method
      validate_re($translation_method_real, '^(nsswitch|umich_ldap|static)$', "translation_method, <${translation_method}>, does not match regex.")
    }
    'Array': {
      $translation_method_real = inline_template('<%= translation_method.join(\',\') %>')
      # GH: TODO: write valid regex
    }
    default: {
      fail("valid types for translation_method are String and Array. Detected type is <${translation_method_type}>")
    }
  }

  case $::osfamily {
    'RedHat' : {
      $default_pipefs_directory = 'UNSET'
      case $::lsbmajdistrelease {
        '5','6': {
          $default_idmap_service = 'rpcidmapd'
          $default_idmap_package = 'nfs-utils-lib'
        }
        '7': {
          $default_idmap_service = 'nfs-idmap'
          $default_idmap_package = 'libnfsidmap'
        }
      }
    }
    'Suse' : {
      $default_idmap_package    = 'nfsidmap'
      $default_pipefs_directory = '/var/lib/nfs/rpc_pipefs'
    }
    default: {
      fail( "idmap only supports RedHat and Suse osfamilies, not ${::osfamily}" )
    }
  }

  if $idmap_package == 'USE_DEFAULTS' {
    $idmap_package_real = $default_idmap_package
  } else {
    $idmap_package_real = $idmap_package
  }

  if $idmapd_service_name == 'USE_DEFAULTS' {
    $idmapd_service_name_real = $default_idmap_service
  } else {
    $idmapd_service_name_real = $idmapd_service_name
  }

  if $pipefs_directory == 'USE_DEFAULTS' {
    $pipefs_directory_real = $default_pipefs_directory
  } else {
    $pipefs_directory_real = $pipefs_directory
  }

  if $pipefs_directory_real != 'UNSET' {
    validate_absolute_path($pipefs_directory_real)
  }

  package { $idmap_package_real:
    ensure => present,
  }

  file { 'idmapd_conf':
    ensure  => file,
    path    => $idmapd_conf_path,
    content => template('nfs/idmapd.conf.erb'),
    owner   => $idmapd_conf_owner,
    group   => $idmapd_conf_group,
    mode    => $idmapd_conf_mode,
    require => Package[$idmap_package_real],
  }

  if $::osfamily == 'RedHat' {

    service { 'idmapd_service':
      ensure     => running,
      name       => $idmapd_service_name_real,
      enable     => $idmapd_service_enable,
      hasstatus  => $idmapd_service_hasstatus,
      hasrestart => $idmapd_service_hasrestart,
      subscribe  => File['idmapd_conf'],
    }
  }
}
