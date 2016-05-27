require_relative 'pacemaker_xml'

module Serverspec::Type
  # This Serverspec type can do the check on the Pacemaker resource object
  class Pacemaker_resource < PacemakerXML
    # Check if this object is present
    # @return [true,false]
    def present?
      primitive_exists? @name
    end

    # The full name of the resource
    # It will have a prefix is the resource is complex
    # @return [String]
    def full_name
      primitive_full_name @name
    end

    alias exists? present?

    # The data object from the library or nil if there is no object
    # @return [Hash,nil]
    def instance
      primitives[@name]
    end

    # The base class of this resource (i.e. ocf, lsb)
    # @return [String,nil]
    def res_class
      primitive_class @name
    end

    # The provider of this resource (i.e. heartbeat, pacemaker)
    # @return [String,nil]
    def res_provider
      primitive_provider @name
    end

    # The actual resource type (i.e. Dummy, IPaddr)
    # @return [String,nil]
    def res_type
      primitive_type @name
    end

    # The hash of instance attribute (configuration parameters)
    # @return [Hash,nil]
    def instance_attributes
      return unless instance
      import_attributes_structure instance['instance_attributes']
    end

    alias parameters instance_attributes

    # The hash of this resource's meta attributes (i.e. resource-stickiness)
    # @return [Hash,nil]
    def meta_attributes
      return unless instance
      import_attributes_structure instance['meta_attributes']
    end

    alias metadata meta_attributes

    # Is this resource complex or simple? (master, clone, simple)
    # @return [String,nil]
    def complex_type
      complex_type = primitive_complex_type @name
      complex_type = complex_type.to_s if complex_type.is_a? Symbol
      complex_type
    end

    # The hash of complex resource related metadata values
    # @return [Hash,nil]
    def complex_meta_attributes
      return unless instance
      import_attributes_structure instance.fetch('complex', {}).fetch('meta_attributes', nil)
    end

    alias complex_metadata complex_meta_attributes

    # Check if this resource is complex
    # nil if not exists
    # @return [true,false,nil]
    def complex?
      primitive_is_complex? @name
    end

    # Check if this resource is simple
    # nil if not exists
    # @return [true,false,nil]
    def simple?
      primitive_is_simple? @name
    end

    # Check if this resource is clone
    # nil if not exists
    # @return [true,false,nil]
    def clone?
      primitive_is_clone? @name
    end

    # Check if this resource is master
    # nil if not exists
    # @return [true,false,nil]
    def master?
      primitive_is_master? @name
    end

    alias multi_state? master?

    # Check if this resource is in group
    # nil if not exists
    # @return [true,false,nil]
    def group?
      primitive_in_group? @name
    end

    # Get the name of the resource group if
    # this resource belongs to one
    # nil if not exists
    # @return [String,nil]
    def group_name
      primitive_group @name
    end

    # Check if this resource have Pacemaker management enabled
    # nil if not exists
    # @return [true,false,nil]
    def managed?
      primitive_is_managed? @name
    end

    # Check if this resource has Started target state
    # It doesn't mean that it's actually running, and constraints
    # may prevent it from being run at all.
    # nil if not exists
    # @return [true,false,nil]
    def started?
      primitive_is_started? @name
    end

    # Get the current actual status of the resource.
    # It can be start, stop, master and nil(unknown)
    # @return [String,nil]
    def status(node=nil)
      primitive_status @name, node
    end

    # Check if this resource is currently running
    # nil if not exists
    # @return [true,false,nil]
    def running?
      primitive_is_running? @name
    end

    # Check if this resource have been failed
    # nil if not exists
    # @return [true,false,nil]
    def failed?
      primitive_has_failures? @name
    end

    # Check if this resource is running is the master mode
    # nil if not exists
    # @return [true,false,nil]
    def master_running?
      primitive_has_master_running? @name
    end

    # check if the resource has the
    # service location on this node
    # @return [true,false,nil]
    def has_location_on?(node)
      return unless exists?
      service_location_exists? full_name, node
    end

    # The array of this resource operations
    # @return [Array<Hash>]
    def operations
      return unless instance
      return unless instance['operations']
      operations_data = []
      sort_data(instance['operations']).each do |operation|
        operation.delete 'id'
        operations_data << operation
      end
      operations_data
    end

    # Test representation
    def to_s
      "Pacemaker_resource #{@name}"
    end
  end
end

# Define the object creation function
def pacemaker_resource(*args)
  name = args.first
  Serverspec::Type::Pacemaker_resource.new(name)
end
