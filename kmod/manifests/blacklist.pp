/*

== Definition: kmod::blacklist

Set a kernel module as blacklisted.

Parameters:
- *ensure*: present/absent;
- *file*: optionally, set the file where the stanza is written.

Example usage:

  kmod::blacklist { 'pcspkr': }

*/

define kmod::blacklist(
  $ensure=present,
  $file='/etc/modprobe.d/blacklist.conf'
) {
  kmod::generic {"blacklist ${name}":
    ensure  => $ensure,
    type    => 'blacklist',
    module  => $name,
    file    => $file,
  }
}
