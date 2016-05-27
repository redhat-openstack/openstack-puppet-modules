require 'rexml/document'
require 'rexml/formatters/pretty'
require 'timeout'
require 'yaml'

require_relative '../../pacemaker/pcs/resource_default'
require_relative '../../pacemaker/pcs/operation_default'
require_relative '../../pacemaker/pcs/cluster_property'
require_relative '../../pacemaker/pcs/pcsd_auth'
require_relative '../../pacemaker/pcs/common'
require_relative '../../pacemaker/options'
require_relative '../../pacemaker/wait'

# the parent provider for all other pcs providers
class Puppet::Provider::PacemakerPCS < Puppet::Provider
  # include instance methods from the pcs library files
  include Pacemaker::PcsCommon
  include Pacemaker::PcsResourceDefault
  include Pacemaker::PcsOperationDefault
  include Pacemaker::PcsClusterProperty
  include Pacemaker::PcsPcsdAuth
  include Pacemaker::Wait
  include Pacemaker::Options

  # include class methods from the pacemaker options
  extend Pacemaker::Options
end
