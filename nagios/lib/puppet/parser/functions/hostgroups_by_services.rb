module Puppet::Parser::Functions
  newfunction(:hostgroups_by_services, :type => :rvalue,
  :doc => "Returns hostgroups matching a provided list of services") do |args|
    result = []
    raise Puppet::ParseError, "Cannot handle empty hostgroups!" unless args[0]
    hostgroups = args[0]
    args[1].split(',').each { |service|
      hostgroups.each do |hostgroup, values|
        if values.has_key?('notes')
          result << hostgroup if values['notes'].include?(service)
        end
      end
    }
    result.flatten.uniq.join(',')
  end
end
