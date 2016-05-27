Pacemaker_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pacemaker_location {
  ensure => 'absent',
}

pacemaker_resource { 'location-test1' :}

pacemaker_location { 'location-test1_location_with_rule' :}

pacemaker_location { 'location-test1_location_with_score' :}

Pacemaker_location<||> ->
Pacemaker_resource<||>
