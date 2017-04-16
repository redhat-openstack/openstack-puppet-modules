Facter.add("openstack_services_enabled") do
  setcode do
    filters = [ 'httpd', 'mariadb', 'mysqld', 'neutron', 'openstack',
      'openvswitch', 'qpidd', 'rabbitmq' ]

    filter  = filters.join('|')
    if system('systemctl --version >/dev/null 2>&1')
     services = %x{systemctl list-unit-files --type=service --full --no-legend --no-pager | awk '/#{filter}/ && $2=="enabled" {print $1}'}
     services.gsub!(/.service$/,'')
    else
      runlevel = %x{runlevel | awk '{print $2}'}.chomp
      services = %x{chkconfig --list | grep "#{runlevel}:on" | awk '/#{filter}/ {print $1}'}
    end
    list = []
    services.split("\n").each {|e| list <<  e }
    list.join(',')
  end
end
