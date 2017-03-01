module Puppet::Parser::Functions
  newfunction(:hostgroup_used, :type => :rvalue, :doc => "") do |args|
    exist = false
    hosts = function_nagios_hosts_get([])
    hosts.each do |host, values|
      exist = true if values['hostgroups'].include?(args[0])
    end
    exist
  end
end
