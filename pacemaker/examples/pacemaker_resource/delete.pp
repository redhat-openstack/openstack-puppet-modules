Pacemaker_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_provider => 'pacemaker',
  primitive_type     => 'Dummy',
}

pacemaker_resource { 'test-simple1' :}

pacemaker_resource { 'test-simple2' :}

pacemaker_resource { 'test-simple-params1' :}

pacemaker_resource { 'test-simple-params2' :}

pacemaker_resource { 'test-clone' :}

pacemaker_resource { 'test-master' :}

pacemaker_resource { 'test-clone-change' :}

pacemaker_resource { 'test-master-change' :}
