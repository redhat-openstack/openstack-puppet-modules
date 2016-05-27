Pacemaker_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pacemaker_colocation {
  ensure => 'present',
}

pacemaker_resource { 'colocation-test1' :
  parameters => {
    'fake' => '1',
  },
}

pacemaker_resource { 'colocation-test2' :
  parameters => {
    'fake' => '2',
  },
}

pacemaker_colocation { 'colocation-test2_with_and_after_colocation-test1' :
  first  => 'colocation-test1',
  second => 'colocation-test2',
  score  => '201',
}

pacemaker_resource { 'colocation-test3' :
  parameters => {
    'fake' => '3',
  },
}

pacemaker_colocation { 'colocation-test3_with_and_after_colocation-test1' :
  first  => 'colocation-test1',
  second => 'colocation-test3',
  score  => '401',
}

Pacemaker_resource<||> ->
Pacemaker_colocation<||>
