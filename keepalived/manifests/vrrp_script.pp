define keepalived::vrrp_script (
  $name_is_process = false,
  $script   = undef,
  $interval = '2',
  $weight   = '2',
) {

  include keepalived::variables

  if (! $name_is_process) and (! $script) {
    fail('You must pass either name_is_process or script.')
  }
  if ($name_is_process) and ($script) {
    fail('You must pass either name_is_process or script, not both.')
  }
  $script_real = $name_is_process ? {
    true  => "killall -0 ${name}",
    false => $script,
  }

  concat::fragment { "keepalived_vrrp_script_${name}":
    target  => $keepalived::variables::keepalived_conf,
    content => template( 'keepalived/keepalived_vrrp_script.erb' ),
    order   => '20',
    notify  => Class[ 'keepalived::service' ],
    require => Class[ 'keepalived::install' ],
  }
}
