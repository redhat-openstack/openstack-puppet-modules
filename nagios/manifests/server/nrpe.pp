# NRPE class for Nagios server
class nagios::server::nrpe (
  $commands,
  $services,
) {

 $command_defaults = {
    'ensure'  => present,
    'target' => '/etc/nagios/conf.d/commands.cfg',
  }

 $service_defaults = {
    'ensure'  => present,
    'target' => '/etc/nagios/conf.d/services.cfg',
  }

  create_resources(nagios_command, $commands, $command_defaults)

  create_resources(nagios_service, $services, $service_defaults)
}
