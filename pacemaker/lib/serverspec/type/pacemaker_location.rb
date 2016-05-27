require_relative 'pacemaker_xml'

module Serverspec::Type
  # This Serverspec type can do the check on the Pacemaker location object
  class Pacemaker_location < PacemakerXML
    # Check if this object is present
    # @return [true,false]
    def present?
      !instance.nil?
    end

    alias exists? present?

    # The data object from the library or nil if there is no object
    # @return [Hash,nil]
    def instance
      constraint_locations[@name]
    end

    # The name of the resource this location is related to
    # @return [String,nil]
    def rsc
      return unless instance
      instance['rsc']
    end

    alias primitive rsc
    alias resource rsc

    # The priority score value
    # Used for node based locations
    # @return [String,nil]
    def score
      return unless instance
      instance['score']
    end

    # The name of the node of this resource
    # It's used for a node based locations
    def node
      return unless instance
      instance['node']
    end

    # The structure with the location rules
    # Used for rule based locations
    def rules
      return unless instance
      instance['rules']
    end

    # Test representation
    def to_s
      "Pacemaker_location #{@name}"
    end
  end
end

# Define the object creation function
def pacemaker_location(*args)
  name = args.first
  Serverspec::Type::Pacemaker_location.new(name)
end
