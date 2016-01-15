define pacemaker::constraint::base (
  $constraint_type,
  $constraint_params = undef,
  $first_resource    = undef,
  $second_resource   = undef,
  $first_action      = undef,
  $second_action     = undef,
  $location          = undef,
  $score             = undef,
  $ensure            = present,
  $tries             = 1,
  $try_sleep         = 10,
) {

  validate_re($constraint_type, ['colocation', 'order', 'location'])

  if($constraint_type == 'order' and ($first_action == undef or $second_action == undef)) {
    fail("Must provide actions when constraint type is order")
  }

  if($constraint_type == 'location' and $location == undef) {
    fail("Must provide location when constraint type is location")
  }

  if($constraint_type == 'location' and $score == undef) {
    fail("Must provide score when constraint type is location")
  }

  if $constraint_params != undef {
    $_constraint_params = "${constraint_params}"
  } else {
    $_constraint_params = ""
  }

  $first_resource_cleaned  = regsubst($first_resource, '(:)', '.', 'G')
  $second_resource_cleaned = regsubst($second_resource, '(:)', '.', 'G')

  if($ensure == absent) {
    if($constraint_type == 'location') {
      $name_cleaned = regsubst($name, '(:)', '.', 'G')
      exec { "Removing location constraint ${name}":
        command => "/usr/sbin/pcs constraint location remove ${name_cleaned}",
        onlyif  => "/usr/sbin/pcs constraint location show --full | grep ${name_cleaned}",
        require => Exec["wait-for-settle"],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    } else {
      exec { "Removing ${constraint_type} constraint ${name}":
        command => "/usr/sbin/pcs constraint ${constraint_type} remove ${first_resource_cleaned} ${second_resource_cleaned}",
        onlyif  => "/usr/sbin/pcs constraint ${constraint_type} show | grep ${first_resource_cleaned} | grep ${second_resource_cleaned}",
        require => Exec["wait-for-settle"],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    }
  } else {
    case $constraint_type {
      'colocation': {
        fail("Deprecated use pacemaker::constraint::colocation")
        exec { "Creating colocation constraint ${name}":
          command => "/usr/sbin/pcs constraint colocation add ${first_resource_cleaned} ${second_resource_cleaned} ${score}",
          unless  => "/usr/sbin/pcs constraint colocation show | grep ${first_resource_cleaned} | grep ${second_resource_cleaned} > /dev/null 2>&1",
          require => [Exec["wait-for-settle"],Package["pcs"]],
          tries     => $tries,
          try_sleep => $try_sleep,
        }
      }
      'order': {
        exec { "Creating order constraint ${name}":
          command => "/usr/sbin/pcs constraint order ${first_action} ${first_resource_cleaned} then ${second_action} ${second_resource_cleaned} ${_constraint_params}",
          unless  => "/usr/sbin/pcs constraint order show | grep ${first_resource_cleaned} | grep ${second_resource_cleaned} > /dev/null 2>&1",
          require => [Exec["wait-for-settle"],Package["pcs"]],
          tries     => $tries,
          try_sleep => $try_sleep,
        }
      }
      'location': {
        fail("Deprecated use pacemaker::constraint::location")
        exec { "Creating location constraint ${name}":
          command => "/usr/sbin/pcs constraint location add ${name} ${first_resource_cleaned} ${location} ${score}",
          unless  => "/usr/sbin/pcs constraint location show | grep ${first_resource_cleaned} > /dev/null 2>&1",
          require => [Exec["wait-for-settle"],Package["pcs"]],
          tries     => $tries,
          try_sleep => $try_sleep,
        }
      }
    }
  }
}
