pacemaker_property { 'cluster-delay' :
  ensure => 'present',
  value  =>  '50',
}

pacemaker_property { 'batch-limit' :
  ensure => 'present',
  value  =>  '50',
}
