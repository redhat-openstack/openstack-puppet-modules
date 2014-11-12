# these parameters should be considered to be constant
class xinetd::params {
  if($::operatingsystem == 'Fedora' and (is_integer($::operatingsystemrelease) and $::operatingsystemrelease >= 16 or $::operatingsystemrelease == "Rawhide")){
     $xinetd_restart_command = '/usr/bin/systemctl restart xinetd.service'
  } else {
     $xinetd_restart_command = '/etc/init.d/xinetd reload'
  }
}
