define pacemaker::constraint::colocation ($source,
                                          $target,
                                          $score,
                                          $master_slave=false,
                                          $ensure=present) {
    pcmk_constraint {"colo-$source-$target":
       constraint_type => colocation,
       resource        => $source,
       location        => $target,
       score           => $score,
       master_slave    => $master_slave,
       ensure          => $ensure,
       require => Exec["wait-for-settle"],
   }
}

