#
# Class to execute ironic dbsync
#
# == Parameters
#
# [*extra_params*]
#   (optional) String of extra command line parameters to append
#   to the ironic-dbsync command.
#   Defaults to undef
#
class ironic::db::sync(
  $extra_params  = undef,
) {

  include ::ironic::params

  Package<| tag == 'ironic-package' |> ~> Exec['ironic-dbsync']
  Exec['ironic-dbsync'] ~> Service <| tag == 'ironic-service' |>

  Ironic_config<||> -> Exec['ironic-dbsync']
  Ironic_config<| title == 'database/connection' |> ~> Exec['ironic-dbsync']

  exec { 'ironic-dbsync':
    command     => "${::ironic::params::dbsync_command} ${extra_params}",
    path        => '/usr/bin',
    # Ubuntu packaging is running dbsync command as root during ironic-common
    # postinstall script so when Puppet tries to run dbsync again, it fails
    # because it is run with ironic user.
    # This is a temporary patch until it's changed in Packaging
    # https://bugs.launchpad.net/cloud-archive/+bug/1450942
    user        => 'root',
    refreshonly => true,
    logoutput   => on_failure,
  }
}
