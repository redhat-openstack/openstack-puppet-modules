/*

== Definition: kmod::install

Set a kernel module as installed.

Parameters:
- *ensure*: present/absent;
- *command*: optionally, set the command associated with the kernel module;
- *file*: optionally, set the file where the stanza is written.

Example usage:

  kmod::install { 'pcspkr': }

*/

define kmod::install(
  $ensure=present,
  $command='/bin/true',
  $file='/etc/modprobe.d/modprobe.conf'
) {
  kmod::generic {"install ${name}":
    ensure   => $ensure,
    type     => 'install',
    module   => $name,
    command  => $command,
    file     => $file,
  }
}
