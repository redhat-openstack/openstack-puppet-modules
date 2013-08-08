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
  $template                = undef,
  $template_body           = undef,
  $collects                = [],
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
  file { $title:
    path                    => $path,
    backup                  => $backup,
    checksum                => $checksum,
    content                 => "To be replaced by datacat_collector[${title}]\n",
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

  $template_real = $template ? {
    default => $template,
    undef   => 'inline',
  }

  $template_body_real = $template_body ? {
    default => $template_body,
    undef   => template_body($template_real),
  }

  datacat_collector { $title:
    template        => $template_real,
    template_body   => $template_body_real,
    target_resource => File[$title], # when we evaluate we modify the private data of this resource
    target_field    => 'content',
    collects        => $collects,
    before          => File[$title], # we want to evaluate before that resource so it can do the work
  }
}
