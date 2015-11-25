# == Class: gnocchi::db
#
#  Configure the Gnocchi database
#
# === Parameters
#
# [*database_connection*]
#   Url used to connect to database.
#   (Optional) Defaults to 'sqlite:////var/lib/gnocchi/gnocchi.sqlite'.
#
# [*ensure_package*]
#   (optional) The state of gnocchi packages
#   Defaults to 'present'
#
class gnocchi::db (
  $database_connection = 'sqlite:////var/lib/gnocchi/gnocchi.sqlite',
  $ensure_package      = 'present',
) inherits gnocchi::params {

  # NOTE(spredzy): In order to keep backward compatibility we rely on the pick function
  # to use gnocchi::<myparam> if gnocchi::db::<myparam> isn't specified.
  $database_connection_real = pick($::gnocchi::database_connection, $database_connection)

  validate_re($database_connection_real,
    '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  if $database_connection_real {
    case $database_connection_real {
      /^mysql:\/\//: {
        $backend_package = false
        require 'mysql::bindings'
        require 'mysql::bindings::python'
      }
      /^postgresql:\/\//: {
        $backend_package = false
        require 'postgresql::lib::python'
      }
      /^sqlite:\/\//: {
        $backend_package = $::gnocchi::params::sqlite_package_name
      }
      default: {
        fail('Unsupported backend configured')
      }
    }

    if $backend_package and !defined(Package[$backend_package]) {
      package {'gnocchi-backend-package':
        ensure => present,
        name   => $backend_package,
        tag    => 'openstack',
      }
    }

    gnocchi_config {
      'indexer/url': value => $database_connection_real, secret => true;
    }

    package { 'gnocchi-indexer-sqlalchemy':
      ensure => $ensure_package,
      name   => $::gnocchi::params::indexer_package_name,
      tag    => ['openstack', 'gnocchi-package'],
    }
  }

}
