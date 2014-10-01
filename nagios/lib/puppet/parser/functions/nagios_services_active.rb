module Puppet::Parser::Functions
  newfunction(:nagios_services_active, :type => :rvalue, :doc => "") do |args|
    services = {}
    args[0].each do |name, values|
      if function_hostgroup_used([values['hostgroup_name']])
        services.merge!({ name => values })
      end
    end
    services
  end
end
