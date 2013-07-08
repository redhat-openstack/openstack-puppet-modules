class { 'snmp':
  ro_community        => 'SeCrEt',
  service_ensure      => 'stopped',
  trap_service_ensure => 'running',
  trap_service_enable => true,
  trap_handlers       => [
    'traphandle default /usr/bin/perl /usr/bin/traptoemail me@somewhere.local',
    'traphandle IF-MIB::linkDown /home/nba/bin/traps down',
  ],
}
