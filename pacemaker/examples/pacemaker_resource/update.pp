Pacemaker_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_provider => 'pacemaker',
  primitive_type     => 'Dummy',
}

pacemaker_resource { 'test-simple1' :
  parameters => {
    'fake' => '2',
  },
}

pacemaker_resource { 'test-simple2' :
  parameters => {
    'fake' => '3',
  },
}

pacemaker_resource { 'test-simple-params1' :
  parameters => {
    'fake' => '4',
  },
  metadata   => {
    'migration-threshold' => '4',
    'failure-timeout'     => '121',
  },
  operations => {
    'monitor' => {
      'interval' => '21',
      'timeout'  => '11',
    },
    'start'   => {
      'timeout' => '31',
    },
    'stop'    => {
      'timeout' => '31',
    },
  },
}

pacemaker_resource { 'test-simple-params2' :
  parameters => {
    'fake' => '5',
  },
  metadata   => {
    'migration-threshold' => '4',
    'failure-timeout'     => '121',
  },
  operations => [
    {
      'name'     => 'monitor',
      'interval' => '11',
      'timeout'  => '11',
    },
    {
      'name'     => 'monitor',
      'interval' => '61',
      'timeout'  => '11',
    },
    {
      'name'    => 'start',
      'timeout' => '31',
    },
    {
      'name'    => 'stop',
      'timeout' => '31',
    },
  ],
}

pacemaker_resource { 'test-clone' :
  complex_type     => 'clone',
  complex_metadata => {
    'interleave' => true,
  },
  parameters       => {
    'fake' => '6',
  },
}

pacemaker_resource { 'test-master' :
  primitive_type   => 'Stateful',
  complex_type     => 'master',
  complex_metadata => {
    'interleave' => true,
    'master-max' => '1',
  },
  parameters       => {
    'fake' => '7',
  },
}

pacemaker_resource { 'test-clone-change' :
  primitive_type   => 'Stateful',
  complex_type     => 'clone',
  parameters       => {
    'fake' => '8',
  },
}

pacemaker_resource { 'test-master-change' :
  primitive_type   => 'Stateful',
  complex_type     => 'simple',
  parameters       => {
    'fake' => '9',
  },
}