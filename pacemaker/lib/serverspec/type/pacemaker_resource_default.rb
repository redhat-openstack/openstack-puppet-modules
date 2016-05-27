require_relative 'pacemaker_xml'

module Serverspec::Type
  # This Serverspec type can do the check on the Pacemaker resource defaults object
  class Pacemaker_resource_default < PacemakerXML
    # Check if this object is present
    # @return [true,false]
    def present?
      !instance.nil?
    end

    alias exists? present?

    # The data object from the library or nil if there is no object
    # @return [Hash,nil]
    def instance
      resource_defaults[@name]
    end

    # The value of this object
    # @return [String,nil]
    def value
      return unless instance
      instance['value']
    end

    # Test representation
    def to_s
      "Pacemaker_resource_default #{@name}"
    end
  end
end

# Define the object creation function
def pacemaker_resource_default(*args)
  name = args.first
  Serverspec::Type::Pacemaker_resource_default.new(name)
end
