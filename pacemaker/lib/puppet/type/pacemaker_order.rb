require 'puppet/parameter/boolean'
require 'puppet/property/boolean'

require_relative '../../pacemaker/options'
require_relative '../../pacemaker/type'

Puppet::Type.newtype(:pacemaker_order) do
  desc <<-eof
Type for manipulating Corosync/Pacemkaer ordering entries. Order
entries are another type of constraint that can be put on sets of
primitives but unlike colocation, order does matter. These designate
the order at which you need specific primitives to come into a desired
state before starting up a related primitive.

More information can be found at the following link:

* http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Clusters_from_Scratch/_controlling_resource_start_stop_ordering.html'
  eof

  include Pacemaker::Options
  include Pacemaker::Type

  ensurable

  newparam(:name) do
    desc <<-eof
Name identifier of this ordering entry. This value needs to be unique
across the entire Corosync/Pacemaker configuration since it doesn't have
the concept of name spaces per type."
    eof

    isnamevar
  end

  newparam(:debug, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-eof
Don't actually make changes.

Default: false
    eof

    defaultto false
  end

  newproperty(:first) do
    desc <<-eof
(Mandatory)
Name of the resource that the then resource depends on.
    eof
  end

  newproperty(:second) do
    desc <<-eof
(Mandatory)
Name of the dependent resource
    eof
  end

  newproperty(:score) do
    desc <<-eof
The priority of the this ordered grouping. Primitives can be a part
of multiple order groups and so there is a way to control which
primitives get priority when forcing the order of state changes on
other primitives. This value can be an integer but is often defined
as the string INFINITY.

Default: undef
eof

    validate do |value|
      next if %w(inf INFINITY -inf -INFINITY).include? value
      next if value.to_i.to_s == value
      raise 'Score parameter is invalid, should be +/- INFINITY(or inf) or Integer'
    end

    munge do |value|
      value.gsub 'inf', 'INFINITY'
    end
  end

  newproperty(:first_action) do
    desc <<-eof
The action that the first resource must complete before the second action can be initiated for the then resource.
Allowed values: start, stop, promote, demote.

Default: undef (means start)
    eof

    newvalues(:start, :stop, :promote, :demote)
  end

  newproperty(:second_action) do
    desc <<-eof
The action that the then resource can execute only after the first action on the first resource has completed.
Allowed values: start, stop, promote, demote.

Default: undef (means the value of the first action)
    eof

    newvalues(:start, :stop, :promote, :demote)
  end

  newproperty(:kind) do
    desc <<-eof
How to enforce the constraint. Allowed values:

* optional: Just a suggestion. Only applies if both resources are executing the specified actions.
  Any change in state by the first resource will have no effect on the then resource.
* mandatory: Always. If first does not perform first-action, then will not be allowed to performed then-action.
  If first is restarted, then (if running) will be stopped beforehand and started afterward.
* serialize: Ensure that no two stop/start actions occur concurrently for the resources.
  First and then can start in either order, but one must complete starting before the other can be started.
  A typical use case is when resource start-up puts a high load on the host.
    eof

    newvalues(:optional, :mandatory, :serialize)
  end

  newproperty(:symmetrical, boolean: true, parent: Puppet::Property::Boolean) do
    desc <<-eof
If true, the reverse of the constraint applies for the opposite action
(for example, if B starts after A starts, then B stops before A stops).

Default: undef (means true)
    eof
  end

  newproperty(:require_all, boolean: true, parent: Puppet::Property::Boolean) do
    desc <<-eof
Whether all members of the set must be active before continuing.

Default: undef (means true)
    eof
  end

  autorequire(:service) do
    %w(corosync pacemaker pcsd)
  end

  def autorequire_enabled?
    pacemaker_options[:autorequire_primitives]
  end

  autorequire(:pacemaker_resource) do
    resources = []
    next resources unless autorequire_enabled?
    next resources unless self[:ensure] == :present
    resources << primitive_base_name(self[:first]) if self[:first]
    resources << primitive_base_name(self[:second]) if self[:second]
    debug "Autorequire pacemaker_resources: #{resources.join ', '}" if resources.any?
    resources
  end

  if respond_to? :autobefore
    autobefore(:pacemaker_resource) do
      resources = []
      next resources unless autorequire_enabled?
      next resources unless self[:ensure] == :absent
      resources << primitive_base_name(self[:first]) if self[:first]
      resources << primitive_base_name(self[:second]) if self[:second]
      debug "Autobefore pacemaker_resources: #{resources.join ', '}" if resources.any?
      resources
    end
  end
end
