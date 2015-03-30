define pacemaker::constraint::base ($constraint_type,
                                    $first_resource,
                                    $second_resource = undef,
                                    $first_action    = undef,
                                    $second_action   = undef,
                                    $location        = undef,
                                    $score           = undef,
                                    $ensure          = present,
                                    $tries           = 1,
                                    $try_sleep       = 10,) {

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

  if($ensure == absent) {
    if($constraint_type == 'location') {
      exec { "Removing location constraint ${name}":
        command => "/usr/sbin/pcs constraint location remove ${name}",
        onlyif  => "/usr/sbin/pcs constraint location show --full | grep ${name}",
        require => Exec["wait-for-settle"],
        tries     => $tries,
        try_sleep => $try_sleep,
      }
    } else {
      exec { "Removing ${constraint_type} constraint ${name}":
        command => "/usr/sbin/pcs constraint ${constraint_type} remove ${first_resource} ${second_resource}",
        onlyif  => "/usr/sbin/pcs constraint ${constraint_type} show | grep ${first_resource} | grep ${second_resource}",
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
          command => "/usr/sbin/pcs constraint colocation add ${first_resource} ${second_resource} ${score}",
          unless  => "/usr/sbin/pcs constraint colocation show | grep ${first_resource} | grep ${second_resource} > /dev/null 2>&1",
          require => [Exec["wait-for-settle"],Package["pcs"]],
          tries     => $tries,
          try_sleep => $try_sleep,
        }
      }
      'order': {
        exec { "Creating order constraint ${name}":
          command => "/usr/sbin/pcs constraint order ${first_action} ${first_resource} then ${second_action} ${second_resource}",
          unless  => "/usr/sbin/pcs constraint order show | grep ${first_resource} | grep ${second_resource} > /dev/null 2>&1",
          require => [Exec["wait-for-settle"],Package["pcs"]],
          tries     => $tries,
          try_sleep => $try_sleep,
        }
      }
      'location': {
        fail("Deprecated use pacemaker::constraint::location")
        exec { "Creating location constraint ${name}":
          command => "/usr/sbin/pcs constraint location add ${name} ${first_resource} ${location} ${score}",
          unless  => "/usr/sbin/pcs constraint location show | grep ${first_resource} > /dev/null 2>&1",
          require => [Exec["wait-for-settle"],Package["pcs"]],
          tries     => $tries,
          try_sleep => $try_sleep,
        }
      }
    }
  }
}
