require_relative '../pacemaker_xml'

Puppet::Type.type(:pacemaker_location).provide(:xml, parent: Puppet::Provider::PacemakerXML) do
  desc 'Specific provider for a rather specific type since I currently have no plan to
  abstract corosync/pacemaker vs. keepalived.  This provider will check the state
  of current primitive colocations on the system; add, delete, or adjust various aspects.'

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
    proxy_instance.constraint_locations.map do |title, data|
      parameters = {}
      debug "Prefetch constraint_location: #{title}"
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
  # @param data [Hash] extracted location data
  # will extract the current location data unless a value is provided
  # @param target_structure [Hash] copy data to this structure
  # defaults to the property_hash of this provider
  def retrieve_data(data = nil, target_structure = property_hash)
    debug 'Call: retrieve_data'
    data = constraint_locations.fetch resource[:name], {} unless data
    target_structure[:ensure] = :present
    target_structure[:name] = data['id'] if data['id']
    target_structure[:primitive] = data['rsc'] if data['rsc']
    target_structure[:node] = data['node'] if data['node']
    target_structure[:score] = data['score'] if data['score']
    target_structure[:rules] = data['rules'] if data['rules']
  end

  def exists?
    debug 'Call: exists?'
    out = constraint_location_exists? resource[:name]
    retrieve_data
    debug "Return: #{out}"
    out
  end

  # check if the location ensure is set to present
  # @return [TrueClass,FalseClass]
  def present?
    property_hash[:ensure] == :present
  end

  # Create just adds our resource to the property_hash and flush will take care
  # of actually doing the work.
  def create
    debug 'Call: create'
    self.property_hash = {
        name: resource[:name],
        ensure: :absent,
        primitive: resource[:primitive],
        node: resource[:node],
        score: resource[:score],
        rules: resource[:rules],
    }
  end

  # Unlike create we actually immediately delete the item.
  def destroy
    debug 'Call: destroy'
    constraint_location_remove resource[:name]
    property_hash.clear
    cluster_debug_report "#{resource} destroy"
  end

  # Getter that obtains the primitives array for us that should have
  # been populated by prefetch or instances (depends on if your using
  # puppet resource or not).
  def primitive
    property_hash[:primitive]
  end

  def score
    property_hash[:score]
  end

  def rules
    property_hash[:rules]
  end

  def node
    property_hash[:node]
  end

  # Our setters for the primitives array and score.  Setters are used when the
  # resource already exists so we just update the current value in the property
  # hash and doing this marks it to be flushed.
  def rules=(should)
    property_hash[:rules] = should
  end

  def primitives=(should)
    property_hash[:primitive] = should
  end

  def score=(should)
    property_hash[:score] = should
  end

  def node=(should)
    property_hash[:node] = should
  end

  # Flush is triggered on anything that has been detected as being
  # modified in the property_hash.  It generates a temporary file with
  # the updates that need to be made.  The temporary file is then used
  # as stdin for the crm command.
  def flush
    debug 'Call: flush'
    return unless property_hash && property_hash.any?

    unless primitive_exists? primitive_base_name property_hash[:primitive]
      raise "Primitive '#{property_hash[:primitive]}' does not exist!"
    end

    unless property_hash[:name] && property_hash[:primitive] &&
        (property_hash[:rules] || (property_hash[:score] && property_hash[:node]))
      raise 'Data does not contain all the required fields!'
    end

    location_structure = {}
    location_structure['id'] = property_hash[:name]
    location_structure['rsc'] = property_hash[:primitive]
    location_structure['score'] = property_hash[:score] if property_hash[:score]
    location_structure['node'] = property_hash[:node] if property_hash[:node]
    location_structure['rules'] = property_hash[:rules] if property_hash[:rules]

    location_patch = xml_document
    location_element = xml_rsc_location location_structure
    raise "Could not create XML patch for '#{resource}'" unless location_element
    location_patch.add_element location_element

    if present?
      wait_for_constraint_update xml_pretty_format(location_patch.root), location_structure['id']
    else
      wait_for_constraint_create xml_pretty_format(location_patch.root), location_structure['id']
    end
    cluster_debug_report "#{resource} flush"
  end
end
