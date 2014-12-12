# == Define: types::service
#
define types::service (
  $ensure      = 'running',
  $binary      = undef,
  $control     = undef,
  $enable      = 'true',
  $hasrestart  = undef,
  $hasstatus   = undef,
  $manifest    = undef,
  $path        = undef,
  $pattern     = undef,
  $provider    = undef,
  $restart     = undef,
  $start       = undef,
  $status      = undef,
  $stop        = undef,
) {

  # validate params
  if $ensure != undef {
    validate_re($ensure, '^(stopped|false|running|true)$',
      "types::service::${name}::ensure can only be <stopped>, <false>, <running> or <true> and is set to <${ensure}>")
  }

  if $enable != undef {
    validate_re($enable, '^(true|false|manual)$',
      "types::service::${name}::enable can only be <true>, <false> or <manual> and is set to <${enable}>")
  }

  service { $name:
    ensure     => $ensure,
    binary     => $binary,
    control    => $control,
    enable     => $enable,
    hasrestart => $hasrestart,
    hasstatus  => $hasstatus,
    manifest   => $manifest,
    path       => $path,
    pattern    => $pattern,
    provider   => $provider,
    restart    => $restart,
    start      => $start,
    status     => $status,
    stop       => $stop,
  }
}
