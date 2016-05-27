require 'puppet/parameter/boolean'
require_relative '../../pacemaker/options'
require_relative '../../pacemaker/type'

Puppet::Type.newtype(:pacemaker_location) do
  desc 'Type for manipulating corosync/pacemaker location. Location
  is the set of rules defining the place where resource will be run.
  More information on Corosync/Pacemaker location can be found here:

  * http://www.clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Clusters_from_Scratch/_ensuring_resources_run_on_the_same_host.html'

  include Pacemaker::Options
  include Pacemaker::Type

  ensurable

  newparam(:name) do
    desc "Identifier of the location entry. This value needs to be unique
    across the entire Corosync/Pacemaker configuration since it doesn't have
    the concept of name spaces per type."

    isnamevar
  end

  newparam(:debug, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc "Don't actually make changes"
    defaultto false
  end

  newproperty(:primitive) do
    desc 'Corosync primitive being managed.'
  end

  newproperty(:score) do
    desc 'The score for the node'

    validate do |value|
      break if %w(inf INFINITY -inf -INFINITY).include? value
      break if value.to_i.to_s == value
      raise 'Score parameter is invalid, should be +/- INFINITY(or inf) or Integer'
    end

    munge do |value|
      value.gsub 'inf', 'INFINITY'
    end
  end

  newproperty(:rules, array_matching: :all) do
    desc 'Specify rules for location'

    munge do |rule|
      resource.stringify_data rule
      if @rule_number
        @rule_number += 1
      else
        @rule_number = 0
      end
      resource.munge_rule rule, @rule_number, @resource[:name]
    end

    def insync?(is)
      resource.insync_debug is, should, 'rules'
      super
    end

    def is_to_s(is)
      resource.inspect_to_s is
    end

    def should_to_s(should)
      resource.inspect_to_s should
    end
  end

  newproperty(:node) do
    desc 'The node for which to apply node score'
  end

  autorequire(:service) do
    %w(corosync pacemaker)
  end

  def autorequire_enabled?
    pacemaker_options[:autorequire_primitives]
  end

  autorequire(:pacemaker_resource) do
    resources = []
    next resources unless autorequire_enabled?
    next resources unless self[:ensure] == :present
    resources << primitive_base_name(self[:primitive]) if self[:primitive]
    debug "Autorequire pacemaker_resources: #{resources.join ', '}" if resources.any?
    resources
  end

  if respond_to? :autobefore
    autobefore(:pacemaker_resource) do
      resources = []
      next resources unless autorequire_enabled?
      next resources unless self[:ensure] == :absent
      resources << primitive_base_name(self[:primitive]) if self[:primitive]
      debug "Autobefore pacemaker_resources: #{resources.join ', '}" if resources.any?
      resources
    end
  end
end
