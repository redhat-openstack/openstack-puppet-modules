class { 'snmp':
  ro_community        => 'SeCrEt',
  service_ensure      => 'stopped',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  trap_handlers       => [
    'traphandle default /usr/bin/perl /usr/bin/traptoemail me@somewhere.com',
    'traphandle TRAP-TEST-MIB::demo-trap /home/user/traptest.sh demo-trap',
  ],
}
