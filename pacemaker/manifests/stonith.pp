class pacemaker::stonith ($disable=true) {
  if $disable == true {
    pacemaker::property { 'Disable STONITH':
        property => 'stonith-enabled',
        value    => false,
    }
  } else {
    pacemaker::property { 'Enable STONITH':
        property => 'stonith-enabled',
        value    => true,
    }
  }
}
