define datacat(
  $template,
  $backup                  = undef,
  $checksum                = undef,
  $force                   = undef,
  $group                   = undef,
  $owner                   = undef,
  $mode                    = undef,
  $path                    = $title,
  $replace                 = undef,
  $selinux_ignore_defaults = undef,
  $selrange                = undef,
  $selrole                 = undef,
  $seltype                 = undef,
  $seluser                 = undef,
) {
  file { $path:
    backup                  => $backup,
    checksum                => $checksum,
    content                 => undef, # This will be set by the datacat_collector
    force                   => $force,
    group                   => $group,
    mode                    => $mode,
    owner                   => $owner,
    replace                 => $replace,
    selinux_ignore_defaults => $selinux_ignore_defaults,
    selrange                => $selrange,
    selrole                 => $selrole,
    seltype                 => $seltype,
    seluser                 => $seluser,
  }

  datacat_collector { $path:
    template      => $template,
    template_body => template_body($template),
    loglevel      => debug,
    before        => File[$title], # when we evaluate we modify the private data of File
  }
}
