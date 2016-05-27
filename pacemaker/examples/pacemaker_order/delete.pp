Pacemaker_resource {
  ensure             => 'absent',
  primitive_class    => 'ocf',
  primitive_type     => 'Dummy',
  primitive_provider => 'pacemaker',
}

Pacemaker_order {
  ensure => 'absent',
}

pacemaker_resource { 'order-test1' :}

pacemaker_resource { 'order-test2' :}

pacemaker_order { 'order-test2_after_order-test1_score' :}

pacemaker_order { 'order-test2_after_order-test1_kind' :}

Pacemaker_order<||> ->
Pacemaker_resource<||>
