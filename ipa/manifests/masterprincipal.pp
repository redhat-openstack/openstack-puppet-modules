define ipa::masterprincipal (
  $host    = $name,
  $present = true,
  $realm   = {}
) {

  $principals = suffix(prefix([$host], 'host/'), "@${realm}")

  $ensure = $present ? {
    false   => 'absent',
    default => 'present'
  }

  k5login { '/root/.k5login':
    ensure     => $ensure,
    principals => $principals
  }
}
