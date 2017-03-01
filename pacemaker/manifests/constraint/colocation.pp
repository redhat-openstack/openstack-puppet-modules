define pacemaker::constraint::colocation ($source,
                                          $target,
                                          $score,
                                          $ensure=present) {
    pcmk_constraint {"colo-$source-$target":
       constraint_type => colocation,
       resource        => $source,
       location        => $target,
       score           => $score,
       ensure          => $ensure,
       require => Exec["wait-for-settle"],
   }
}

