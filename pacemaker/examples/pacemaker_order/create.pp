Pacemaker_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pacemaker_order {
  ensure => 'present',
}

pacemaker_resource { 'order-test1' :
  parameters => {
    'fake' => '1',
  },
}

pacemaker_resource { 'order-test2' :
  parameters => {
    'fake' => '2',
  },
}

pacemaker_order { 'order-test2_after_order-test1_score' :
  first  => 'order-test1',
  second => 'order-test2',
  score  => '200',
}

# Pacemaker 1.1+
pacemaker_order { 'order-test2_after_order-test1_kind' :
  first         => 'order-test1',
  first_action  => 'promote',
  second        => 'order-test2',
  second_action => 'demote',
  kind          => 'mandatory',
  symmetrical   => true,
}

Pacemaker_resource<||> ->
Pacemaker_order<||>
