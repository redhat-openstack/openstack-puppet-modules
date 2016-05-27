Pacemaker_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pacemaker_colocation {
  ensure => 'absent',
}

pacemaker_resource { 'colocation-test1' :}

pacemaker_resource { 'colocation-test2' :}

pacemaker_colocation { 'colocation-test2_with_and_after_colocation-test1' :}

pacemaker_resource { 'colocation-test3' :}

pacemaker_colocation { 'colocation-test3_with_and_after_colocation-test1' :}

Pacemaker_colocation<||> ->
Pacemaker_resource<||>
