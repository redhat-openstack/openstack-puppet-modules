# == Define: types::mount
#
define types::mount (
  $device,
  $fstype,
  $ensure      = mounted,
  $atboot      = true,
  $blockdevice = undef,
  $dump        = undef,
  $options     = undef,
  $pass        = undef,
  $provider    = undef,
  $remounts    = undef,
  $target      = undef,
) {

  # validate params
  validate_re($ensure, '^(present)|(unmounted)|(absent)|(mounted)$',
    "types::mount::${name}::ensure is invalid and does not match the regex.")
  validate_absolute_path($name)

  # ensure target exists
  include common
  common::mkdir_p { $name: }

  # Solaris cannot handle 'defaults' as a mount option. A common use case would
  # be to have NFS exports specified in Hiera for multiple systems and if the
  # system is Solaris, it would throw an error.
  if $options == 'defaults' and $::osfamily == 'Solaris' {
    $options_real = '-'
  } else {
    $options_real = $options
  }

  mount { $name:
    ensure      => $ensure,
    name        => $name,
    atboot      => $atboot,
    blockdevice => $blockdevice,
    device      => $device,
    dump        => $dump,
    fstype      => $fstype,
    options     => $options_real,
    pass        => $pass,
    provider    => $provider,
    remounts    => $remounts,
    target      => $target,
    require     => Common::Mkdir_p[$name],
  }
}
