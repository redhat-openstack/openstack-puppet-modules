require 'rubygems'

require 'rexml/document'
require 'rexml/formatters/pretty'
require 'timeout'
require 'yaml'

require_relative '../../pacemaker/xml/cib'
require_relative '../../pacemaker/xml/constraints'
require_relative '../../pacemaker/xml/constraint_colocations'
require_relative '../../pacemaker/xml/constraint_locations'
require_relative '../../pacemaker/xml/constraint_orders'
require_relative '../../pacemaker/xml/helpers'
require_relative '../../pacemaker/xml/nodes'
require_relative '../../pacemaker/xml/primitives'
require_relative '../../pacemaker/xml/properties'
require_relative '../../pacemaker/xml/resource_default'
require_relative '../../pacemaker/xml/operation_default'
require_relative '../../pacemaker/xml/status'
require_relative '../../pacemaker/xml/debug'
require_relative '../../pacemaker/options'
require_relative '../../pacemaker/wait'
require_relative '../../pacemaker/xml/xml'
require_relative '../../pacemaker/type'

# Serverspec Type collection module
module Serverspec::Type
  # This class in the basic abstract type for all Pacemaker Serverspec types
  # It includes the parts of the pacemaker library and real types
  # should just inherit from it to use the library functions.
  class PacemakerXML < Base
    include Pacemaker::Cib
    include Pacemaker::Constraints
    include Pacemaker::ConstraintOrders
    include Pacemaker::ConstraintLocations
    include Pacemaker::ConstraintColocations
    include Pacemaker::Helpers
    include Pacemaker::Nodes
    include Pacemaker::Options
    include Pacemaker::Primitives
    include Pacemaker::Properties
    include Pacemaker::Debug
    include Pacemaker::ResourceDefault
    include Pacemaker::OperationDefault
    include Pacemaker::Status
    include Pacemaker::Wait
    include Pacemaker::Xml
    include Pacemaker::Type

    [:cibadmin, :crm_attribute, :crm_node, :crm_resource, :crm_attribute].each do |tool|
      define_method(tool) do |*args|
        command = [tool.to_s] + args
        @runner.run_command(command).stdout
      end
    end

    # override the debug method
    def debug(msg)
      puts msg
    end

    alias info debug
  end
end
