class pacemaker::resource_defaults(
  $defaults,
  $ensure = 'present',
) {
  create_resources(
    "pcmk_resource_default",
    $defaults,
    {
      ensure => $ensure,
    }
  )
}
