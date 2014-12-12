# == Define: types::file
#
define types::file (
  $ensure                  = present,
  $owner                   = root,
  $group                   = root,
  $mode                    = 0644,
  $backup                  = undef,
  $checksum                = undef,
  $content                 = undef,
  $force                   = undef,
  $ignore                  = undef,
  $links                   = undef,
  $provider                = undef,
  $purge                   = undef,
  $recurse                 = undef,
  $recurselimit            = undef,
  $replace                 = undef,
  $selinux_ignore_defaults = undef,
  $selrange                = undef,
  $selrole                 = undef,
  $seltype                 = undef,
  $seluser                 = undef,
  $show_diff               = undef,
  $source                  = undef,
  $sourceselect            = undef,
  $target                  = undef,
) {

  # validate params
  validate_re($ensure, '^(present)|(absent)|(file)|(directory)|(link)$',
    "types::file::${name}::ensure is invalid and does not match the regex.")
  validate_absolute_path($name)
  validate_re($mode, '^\d{4}$', "types::file::${name}::mode must be exactly 4 digits.")

  file { $name:
    ensure                  => $ensure,
    owner                   => $owner,
    group                   => $group,
    mode                    => $mode,
    checksum                => $checksum,
    content                 => $content,
    backup                  => $backup,
    force                   => $force,
    ignore                  => $ignore,
    links                   => $links,
    provider                => $provider,
    purge                   => $purge,
    recurse                 => $recurse,
    recurselimit            => $recurselimit,
    replace                 => $replace,
    selinux_ignore_defaults => $selinux_ignore_defaults,
    selrange                => $selrange,
    selrole                 => $selrole,
    seltype                 => $seltype,
    seluser                 => $seluser,
    show_diff               => $show_diff,
    source                  => $source,
    sourceselect            => $sourceselect,
    target                  => $target,
  }
}
