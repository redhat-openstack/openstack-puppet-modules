require_relative '../pacemaker_xml'
require 'set'

Puppet::Type.type(:pacemaker_resource).provide(:xml, parent: Puppet::Provider::PacemakerXML) do
  desc <<-eof
Specific provider for a rather specific type since I currently have no
plan to abstract corosync/pacemaker vs. keepalived. Primitives in
Corosync are the thing we desire to monitor; websites, ipaddresses,
databases, etc, etc. Here we manage the creation and deletion of
these primitives. We will accept a hash for what Corosync calls
operations and parameters. A hash is used instead of constucting a
better model since these values can be almost anything.'
  eof

  commands cibadmin: 'cibadmin'
  commands crm_attribute: 'crm_attribute'
  commands crm_node: 'crm_node'
  commands crm_resource: 'crm_resource'
  commands crm_attribute: 'crm_attribute'

  attr_accessor :property_hash
  attr_accessor :resource

  def self.instances
    debug 'Call: self.instances'
    proxy_instance = new
    instances = []
    proxy_instance.primitives.map do |title, data|
      parameters = {}
      debug "Prefetch resource: #{title}"
      proxy_instance.retrieve_data data, parameters
      instance = new(parameters)
      instance.cib = proxy_instance.cib
      instances << instance
    end
    instances
  end

  def self.prefetch(catalog_instances)
    debug 'Call: self.prefetch'
    return unless pacemaker_options[:prefetch]
    discovered_instances = instances
    discovered_instances.each do |instance|
      next unless catalog_instances.key? instance.name
      catalog_instances[instance.name].provider = instance
    end
  end

  # retrieve data from library to the target_structure
  # @param data [Hash] extracted primitive data
  # will extract the current primitive data unless a value is provided
  # @param target_structure [Hash] copy data to this structure
  # defaults to the property_hash of this provider
  def retrieve_data(data = nil, target_structure = property_hash)
    debug 'Call: retrieve_data'
    data = primitives.fetch resource[:name], {} unless data
    target_structure[:ensure] = :present
    target_structure[:complex_type] = :simple
    copy_value data, 'id', target_structure, :name
    copy_value data, 'class', target_structure, :primitive_class
    copy_value data, 'provider', target_structure, :primitive_provider
    copy_value data, 'type', target_structure, :primitive_type

    if data['complex']
      data_complex_type = data['complex']['type'].to_sym
      target_structure[:complex_type] = data_complex_type if complex_types.include? data_complex_type
      complex_metadata = import_attributes_structure data['complex']['meta_attributes']
      target_structure[:complex_metadata] = complex_metadata if complex_metadata
    end

    if data['instance_attributes']
      parameters_data = import_attributes_structure data['instance_attributes']
      if parameters_data && parameters_data.is_a?(Hash)
        target_structure[:parameters] = parameters_data if parameters_data
      end
    end

    if data['meta_attributes']
      metadata_data = import_attributes_structure data['meta_attributes']
      if metadata_data && metadata_data.is_a?(Hash)
        target_structure[:metadata] = metadata_data
      end
    end

    if data['operations']
      operations_set = Set.new
      data['operations'].each do |_id, operation|
        operation.delete 'id'
        operations_set.add operation
      end
      target_structure[:operations] = operations_set
    end
  end

  def exists?
    debug 'Call: exists?'
    out = primitive_exists? resource[:name]
    retrieve_data
    debug "Return: #{out}"
    out
  end

  # check if the location ensure is set to present
  # @return [TrueClass,FalseClass]
  def present?
    property_hash[:ensure] == :present
  end

  # check if the complex type of the resource is changing
  # and we have to recreate it
  # @return [true,false]
  def complex_change?
    current_complex_type = primitive_complex_type(name) || :simple
    current_complex_type != complex_type
  end

  # is this primitive complex?
  # @return [true,false]
  def is_complex?
    complex_types.include? complex_type
  end

  # list of the actually supported complex types
  # @return [Array<Symbol>]
  def complex_types
    [:clone, :master]
  end

  # Create just adds our resource to the property_hash and flush will take care
  # of actually doing the work.
  def create
    debug 'Call: create'
    self.property_hash = {
        ensure: :absent,
        name: resource[:name],
    }

    parameters = [
        :primitive_class,
        :primitive_provider,
        :primitive_type,
        :parameters,
        :operations,
        :metadata,
        :complex_type,
        :complex_metadata,
    ]

    parameters.each do |parameter|
      send "#{parameter}=".to_sym, resource[parameter]
    end
  end

  # use cibadmin to remove the XML section describing this primitive
  def remove_primitive
    return unless primitive_exists? resource[:name]
    stop_service
    primitive_tag = 'primitive'
    primitive_tag = primitive_complex_type resource[:name] if primitive_is_complex? resource[:name]
    wait_for_primitive_remove "<#{primitive_tag} id='#{primitive_full_name resource[:name]}'/>\n", resource[:name]
    property_hash[:ensure] = :absent
  end

  # stop the primitive before its removal
  def stop_service
    stop_primitive primitive_full_name resource[:name]
    cleanup_primitive primitive_full_name resource[:name]
    wait_for_stop resource[:name]
  end

  # Unlike create we actually immediately delete the item.  Corosync forces us
  # to "stop" the primitive before we are able to remove it.
  def destroy
    debug 'Call: destroy'
    remove_primitive
    property_hash.clear
    cluster_debug_report "#{resource} destroy"
  end

  # Getters that obtains the parameters and operations defined in our primitive
  # that have been populated by prefetch or instances (depends on if your using
  # puppet resource or not).
  def parameters
    property_hash[:parameters]
  end

  def operations
    property_hash[:operations]
  end

  def metadata
    property_hash[:metadata]
  end

  def complex_metadata
    property_hash[:complex_metadata]
  end

  def complex_type
    if property_hash[:complex_type].respond_to? :to_sym
      property_hash[:complex_type].to_sym
    else
      property_hash[:complex_type]
    end
  end

  def primitive_class
    property_hash[:primitive_class]
  end

  def primitive_provider
    property_hash[:primitive_provider]
  end

  def primitive_type
    property_hash[:primitive_type]
  end

  def full_name
    if is_complex?
      "#{name}-#{complex_type}"
    else
      name
    end
  end

  # Our setters for parameters and operations.  Setters are used when the
  # resource already exists so we just update the current value in the
  # property_hash and doing this marks it to be flushed.
  def parameters=(should)
    property_hash[:parameters] = should
  end

  def operations=(should)
    should = should.first if should.is_a? Array
    property_hash[:operations] = should
  end

  def metadata=(should)
    property_hash[:metadata] = should
  end

  def complex_metadata=(should)
    property_hash[:complex_metadata] = should
  end

  def complex_type=(should)
    property_hash[:complex_type] = should
  end

  def primitive_class=(should)
    property_hash[:primitive_class] = should
  end

  def primitive_provider=(should)
    property_hash[:primitive_provider] = should
  end

  def primitive_type=(should)
    property_hash[:primitive_type] = should
  end

  # Flush is triggered on anything that has been detected as being
  # modified in the property_hash.  It generates a temporary file with
  # the updates that need to be made.  The temporary file is then used
  # as stdin for the crm command.  We have to do a bit of munging of our
  # operations and parameters hash to eventually flatten them into a string
  # that can be used by the crm command.
  def flush
    debug 'Call: flush'
    return unless property_hash && property_hash.any?

    unless primitive_class && primitive_type
      raise 'Primitive class and type should be present!'
    end

    # if the complex type is changing we have to remove the resource
    # and create a new one with the correct complex type
    if complex_change?
      debug 'Changing the complex type of the primitive. First remove and then create it!'
      remove_primitive
    end

    # basic primitive structure
    primitive_structure = {}
    primitive_structure['id'] = name
    primitive_structure['name'] = full_name
    primitive_structure['class'] = primitive_class
    primitive_structure['provider'] = primitive_provider if primitive_provider
    primitive_structure['type'] = primitive_type

    # complex structure
    if is_complex?
      complex_structure = {}
      complex_structure['type'] = complex_type
      complex_structure['id'] = full_name

      # complex meta_attributes structure
      if complex_metadata && complex_metadata.any?
        meta_attributes_structure = export_attributes_structure complex_metadata, 'meta_attributes'
        complex_structure['meta_attributes'] = meta_attributes_structure if meta_attributes_structure
      end
      primitive_structure['complex'] = complex_structure
    end

    # operations structure
    if operations && operations.any?
      primitive_structure['operations'] = {}
      operations.each do |operation|
        if operation.is_a?(Array) && operation.length == 2
          # operations were provided and Hash { name => { parameters } }, convert it
          operation_name = operation[0]
          operation = operation[1]
          operation['name'] = operation_name unless operation['name']
        end
        unless operation['id']
          # there is no id provided, generate it
          id_components = [name, operation['name'], operation['interval']]
          id_components.reject!(&:nil?)
          operation['id'] = id_components.join '-'
        end
        primitive_structure['operations'].store operation['id'], operation
      end
    end

    # instance_attributes structure
    if parameters && parameters.any?
      instance_attributes_structure = export_attributes_structure parameters, 'instance_attributes'
      primitive_structure['instance_attributes'] = instance_attributes_structure if instance_attributes_structure
    end

    # meta_attributes structure
    if metadata && metadata.any?
      meta_attributes_structure = export_attributes_structure metadata, 'meta_attributes'
      primitive_structure['meta_attributes'] = meta_attributes_structure
    end

    # create and apply XML patch
    primitive_patch = xml_document
    primitive_element = xml_primitive primitive_structure
    raise "Could not create XML patch for '#{resource}'" unless primitive_element
    primitive_patch.add_element primitive_element
    if present?
      wait_for_primitive_update xml_pretty_format(primitive_patch.root), primitive_structure['id']
    else
      wait_for_primitive_create xml_pretty_format(primitive_patch.root), primitive_structure['id']
    end
    cluster_debug_report "#{resource} flush"
  end
end
