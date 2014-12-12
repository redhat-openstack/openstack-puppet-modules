/*

== Definition: kmod::generic

Set a kernel module in modprobe.conf (5).

Parameters:
- *type*: type of modprobe stanza (install/blacklist/etc);
- *module*: module name;
- *ensure*: present/absent;
- *command*: optionally, set the command associated with the kernel module;
- *file*: optionally, set the file where the stanza is written.

Example usage:

  kmod::generic {'install pcspkr':
    type   => 'install',
    module => 'pcspkr',
  }

*/

define kmod::generic(
  $type,
  $module,
  $ensure=present,
  $command='',
  $file
) {

  include kmod

  case $ensure {
    present: {
      if $type == 'install' {
        kmod::load { $module:
          ensure  => $ensure,
          require => Augeas["${type} module ${module}"],
        }
      }

      if $command {
        # modprobe.conf usage changes in 0.10.0
        if versioncmp($::augeasversion, '0.9.0') < 0 {
          $augset = "set ${type}[. = '${module}'] '${module} ${command}'"
          $onlyif = "match ${type}[. = '${module} ${command}'] size == 0"
        } else {
          $augset = [
            "set ${type}[. = '${module}'] ${module}",
            "set ${type}[. = '${module}']/command '${command}'",
          ]
          $onlyif = "match ${type}[. = '${module}'] size == 0"
        }
      } else {
        $augset = "set ${type}[. = '${module}'] ${module}"
      }

      augeas {"${type} module ${module}":
        incl    => $file,
        lens    => 'Modprobe.lns',
        changes => $augset,
        onlyif  => $onlyif,
        require => File[$file],
      }
    }

    absent: {
      kmod::load { $module:
        ensure => $ensure,
      }

      augeas {"remove module ${module}":
        incl    => $file,
        lens    => 'Modprobe.lns',
        changes => "rm ${type}[. = '${module}']",
        onlyif  => "match ${type}[. = '${module}'] size > 0",
        require => File[$file],
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }
}
