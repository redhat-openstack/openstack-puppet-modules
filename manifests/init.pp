# Definition: datacat
#
# This definition allows you to declare datacat managed files.
#
# Parameters:
# All parameters are as for the file type, with the addition of a $template
# parameter which is a path to a template to be used as the content of the
# file.
#
# Sample Usage:
#  datacat { '/etc/motd':
#    owner => 'root',
#    group => 'root,
#    template => 'motd/motd.erb',
#  }
#
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
  $seluser                 = undef
) {
  file { $path:
    backup                  => $backup,
    checksum                => $checksum,
    content                 => "To be replaced by datacat_collector[${path}]\n",
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
