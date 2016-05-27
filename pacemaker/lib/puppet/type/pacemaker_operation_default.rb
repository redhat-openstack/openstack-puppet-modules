require 'puppet/parameter/boolean'
require_relative '../../pacemaker/options'
require_relative '../../pacemaker/type'

Puppet::Type.newtype(:pacemaker_operation_default) do
  desc 'Type for manipulating corosync/pacemaker configuration op_defaults.
  Besides the configuration file that is managed by the module the contains
  all these related Corosync types and providers, there is a set of cluster
  op_defaults that can be set and saved inside the CIB (A CIB being a set of
  configuration that is synced across the cluster, it can be exported as XML
  for processing and backup). The type is pretty simple interface for
  setting key/value pairs or removing them completely. Removing them will
  result in them taking on their default value.

  More information on cluster properties can be found here:

  * http://clusterlabs.org/doc/en-US/Pacemaker/1.1-plugin/html/Clusters_from_Scratch/ch05s03s02.html'

  include Pacemaker::Options
  include Pacemaker::Type

  ensurable

  newparam(:name) do
    desc 'Name identifier of this op_defaults. Simply the name of the cluster
    op_defaults. Happily most of these are unique.'

    isnamevar
  end

  newparam(:debug, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Don't actually make any changes"

    defaultto false
  end

  newproperty(:value) do
    desc "Value of the op_defaults. It is expected that this will be a single
    value but we aren't validating string vs. integer vs. boolean because
    cluster op_operations can range the gambit."

    isrequired
  end

  autorequire(:service) do
    %w(corosync pacemaker)
  end
end
