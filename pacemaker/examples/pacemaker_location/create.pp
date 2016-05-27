Pacemaker_resource {
  ensure             => 'present',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pacemaker_location {
  ensure => 'present',
}

pacemaker_resource { 'location-test1' :
  parameters => {
    'fake' => '1',
  },
}

$rules = [
  {
    'score' => '100',
    'expressions' => [
      {
        'attribute' => 'a',
        'operation' => 'defined',
      },
    ]
  },
  {
    'score' => '200',
    'expressions' => [
      {
        'attribute' => 'b',
        'operation' => 'defined',
      },
    ]
  }
]

pacemaker_location { 'location-test1_location_with_rule' :
  primitive => 'location-test1',
  rules     => $rules,
}

pacemaker_location { 'location-test1_location_with_score' :
  primitive => 'location-test1',
  node      => $pacemaker_node_name,
  score     => '200',
}

Pacemaker_resource<||> ->
Pacemaker_location<||>
