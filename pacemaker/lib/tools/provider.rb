require 'rubygems'
require 'puppet'

require_relative '../puppet/provider/pacemaker_xml'

class Puppet::Provider::PacemakerXML
  [:cibadmin, :crm_attribute, :crm_node, :crm_resource, :crm_attribute].each do |tool|
    define_method(tool) do |*args|
      command = [tool.to_s] + args
      if Puppet::Util::Execution.respond_to? :execute
        Puppet::Util::Execution.execute command
      else
        Puppet::Util.execute command
      end
    end
  end

  # override the debug method
  def debug(msg)
    puts msg
  end

  alias info debug
end
