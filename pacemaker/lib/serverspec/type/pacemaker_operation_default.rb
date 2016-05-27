require_relative 'pacemaker_xml'

module Serverspec::Type
  # This Serverspec type can do the check on the Pacemaker operation default object
  class Pacemaker_operation_default < PacemakerXML
    # Check if this object is present
    # @return [true,false]
    def present?
      !instance.nil?
    end

    alias exists? present?

    # The data object from the library or nil if there is no object
    # @return [Hash,nil]
    def instance
      operation_defaults[@name]
    end

    # The value of this object
    # @return [String,nil]
    def value
      return unless instance
      instance['value']
    end

    # Test representation
    def to_s
      "Pacemaker_operation_default #{@name}"
    end
  end
end

# Define the object creation function
def pacemaker_operation_default(*args)
  name = args.first
  Serverspec::Type::Pacemaker_operation_default.new(name)
end
