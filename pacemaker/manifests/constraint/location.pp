define pacemaker::constraint::location ($resource,
                                        $location,
                                        $score,
                                        $ensure='present') {
    pcmk_constraint {"loc-$resource-$location":
       constraint_type => location,
       resource        => $resource,
       location        => $location,
       score           => $score,
       ensure          => $ensure,
       require => Exec["Start Cluster ${corosync::cluster_name}"],
   }
}
 
