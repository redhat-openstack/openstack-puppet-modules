class demo1 {
  notify { 'demo1': }

  datacat { '/tmp/demo1':
    template => 'sheeps',
  }

}

