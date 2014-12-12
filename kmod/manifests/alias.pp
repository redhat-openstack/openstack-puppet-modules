# = Define: kmod::alias
#
# == Example
#
#     kmod::alias { 'bond0':
#       alias => 'bonding',
#     }
#
define kmod::alias(
  $source,
  $ensure = 'present',
  $file   = '/etc/modprobe.d/aliases.conf',
) {

  include kmod

  case $ensure {
    present: {
      $augset = [
        "set alias[. = '${name}'] ${name}",
        "set alias[. = '${name}']/modulename ${source}",
      ]
      $onlyif = "match alias[. = '${name}'] size == 0"


      augeas { "modprobe alias ${name} ${source}":
        incl    => $file,
        lens    => 'Modprobe.lns',
        changes => $augset,
        onlyif  => $onlyif,
        require => File[$file],
      }
    }

    absent: {
      kmod::load { $name:
        ensure => $ensure,
      }

      augeas {"remove modprobe alias ${name}":
        incl    => $file,
        lens    => 'Modprobe.lns',
        changes => "rm alias[. = '${name}']",
        onlyif  => "match alias[. = '${name}'] size > 0",
        require => File[$file],
      }
    }

    default: { err ( "unknown ensure value ${ensure}" ) }
  }
}
