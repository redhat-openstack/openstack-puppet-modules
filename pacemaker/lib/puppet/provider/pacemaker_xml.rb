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

# the parent provider for all other pacemaker providers
# includes all functions from all submodules
class Puppet::Provider::PacemakerXML < Puppet::Provider
  # include instance methods from the pacemaker library files
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

  # include class methods from the pacemaker options
  extend Pacemaker::Options
end
