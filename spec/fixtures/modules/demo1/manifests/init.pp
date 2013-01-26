class demo1 {
  notify { 'demo1': }

  datacat { '/tmp/demo1':
    template => 'sheeps',
  }

  datacat_fragment { 'data foo => 1':
    target => '/tmp/demo1',
    data   => { foo => 1 },
  }
}

