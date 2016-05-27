require_relative 'pacemaker_xml'

module Serverspec::Type
  # This Serverspec type can do the check on the Pacemaker colocation object
  class Pacemaker_colocation < PacemakerXML
    # Check if this object is present
    # @return [true,false]
    def present?
      !instance.nil?
    end

    alias exists? present?

    # The data object from the library or nil if there is no object
    # @return [Hash,nil]
    def instance
      constraint_colocations[@name]
    end

    # The name of the resource which is
    # running on the same node as the first one
    # @return [Strong,nil]
    def rsc
      return unless instance
      instance['rsc']
    end

    alias second rsc

    # The name of the first resource
    # @return [Strong,nil]
    def with_rsc
      return unless instance
      instance['with-rsc']
    end

    alias first with_rsc

    # The priority score value
    # @return [String,nil]
    def score
      return unless instance
      instance['score']
    end

    # Test representation
    def to_s
      "Pacemaker_colocation #{@name}"
    end
  end
end

# Define the object creation function
def pacemaker_colocation(*args)
  name = args.first
  Serverspec::Type::Pacemaker_colocation.new(name)
end
