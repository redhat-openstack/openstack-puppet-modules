#
define collectd::plugin::curl::page (
  $ensure              = 'present',
  $url                 = undef,
  $user                = undef,
  $password            = undef,
  $verifypeer          = undef,
  $verifyhost          = undef,
  $cacert              = undef,
  $header              = undef,
  $post                = undef,
  $measureresponsetime = undef,
  $matches             = [{ }],
  $plugininstance      = $name, # You can have multiple <Page> with the same name.
) {
  include collectd::params
  include collectd::plugin::curl

  $conf_dir = $collectd::params::plugin_conf_dir

  validate_string($url)

  file { "${conf_dir}/curl-${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $collectd::params::root_group,
    content => template('collectd/plugin/curl-page.conf.erb'),
    notify  => Service['collectd'],
  }
}
