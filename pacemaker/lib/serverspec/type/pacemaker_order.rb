require_relative 'pacemaker_xml'

module Serverspec::Type
  # This Serverspec type can do the check on the Pacemaker order object
  class Pacemaker_order < PacemakerXML
    # Check if this object is present
    # @return [true,false]
    def present?
      !instance.nil?
    end

    alias exists? present?

    # The data object from the library or nil if there is no object
    # @return [Hash,nil]
    def instance
      constraint_orders[@name]
    end

    # The resource which should start first
    def first
      return unless instance
      instance['first']
    end

    # The resource that should start after the first one
    def second
      return unless instance
      instance['then']
    end

    alias then second

    # The priority score value
    # @return [String,nil]
    def score
      return unless instance
      instance['score']
    end

    # The action of the first resource that triggers the constraint
    def first_action
      return unless instance
      instance['first-action']
    end

    # The action of the second resource that triggers the constraint
    def second_action
      return unless instance
      instance['then-action']
    end

    alias then_action second_action

    # the enforcement type of the constraint
    def kind
      return unless instance
      return unless instance['kind']
      instance['kind'].downcase
    end

    # The symmetrical setting of the constraint
    def symmetrical
      return unless instance
      instance['symmetrical']
    end

    # The require_all setting of the constraint
    def require_all
      return unless instance
      instance['require-all']
    end

    # Test representation
    def to_s
      "Pacemaker_order #{@name}"
    end
  end
end

# Define the object creation function
def pacemaker_order(*args)
  name = args.first
  Serverspec::Type::Pacemaker_order.new(name)
end
