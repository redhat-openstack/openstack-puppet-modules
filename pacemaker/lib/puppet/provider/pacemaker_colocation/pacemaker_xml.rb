require_relative '../pacemaker_xml'

Puppet::Type.type(:pacemaker_colocation).provide(:xml, parent: Puppet::Provider::PacemakerXML) do
  desc 'Specific provider for a rather specific type since I currently have no plan to
        abstract corosync/pacemaker vs. keepalived.  This provider will check the state
        of current primitive colocations on the system; add, delete, or adjust various
        aspects.'

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
    proxy_instance.constraint_colocations.map do |title, data|
      parameters = {}
      debug "Prefetch constraint_colocation: #{title}"
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
  # @param data [Hash] extracted colocation data
  # will extract the current colocation data unless a value is provided
  # @param target_structure [Hash] copy data to this structure
  # defaults to the property_hash of this provider
  def retrieve_data(data = nil, target_structure = property_hash)
    data = constraint_colocations.fetch resource[:name], {} unless data
    target_structure[:name] = data['id'] if data['id']
    target_structure[:ensure] = :present
    target_structure[:first] = data['with-rsc'] if data['with-rsc']
    target_structure[:first] += ":#{data['with-rsc-role']}" if data['with-rsc-role']
    target_structure[:second] = data['rsc'] if data['rsc']
    target_structure[:second] += ":#{data['rsc-role']}" if data['rsc-role']
    target_structure[:score] = data['score'] if data['score']
  end

  def exists?
    debug 'Call: exists?'
    out = constraint_colocation_exists? resource[:name]
    retrieve_data
    debug "Return: #{out}"
    out
  end

  # check if the colocation ensure is set to present
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
        first: resource[:first],
        second: resource[:second],
        score: resource[:score],
    }
  end

  # Unlike create we actually immediately delete the item.
  def destroy
    debug 'Call: destroy'
    constraint_colocation_remove resource[:name]
    property_hash.clear
    cluster_debug_report "#{resource} destroy"
  end

  # Getter that obtains the our score that should have been populated by
  # prefetch or instances (depends on if your using puppet resource or not).
  def score
    property_hash[:score]
  end

  # Getters that obtains the first and second primitives and score in our
  # ordering definition that have been populated by prefetch or instances
  # (depends on if your using puppet resource or not).
  def first
    property_hash[:first]
  end

  def second
    property_hash[:second]
  end

  # Our setters for the first and second primitives and score.  Setters are
  # used when the resource already exists so we just update the current value
  # in the property hash and doing this marks it to be flushed.
  def first=(should)
    property_hash[:first] = should
  end

  def second=(should)
    property_hash[:second] = should
  end

  def score=(should)
    property_hash[:score] = should
  end

  # Flush is triggered on anything that has been detected as being
  # modified in the property_hash.  It generates a temporary file with
  # the updates that need to be made.  The temporary file is then used
  # as stdin for the crm command.
  def flush
    debug 'Call: flush'
    return unless property_hash && property_hash.any?

    unless property_hash[:name] && property_hash[:score] && property_hash[:first] && property_hash[:second]
      raise 'Data does not contain all the required fields!'
    end

    unless primitive_exists? primitive_base_name property_hash[:first]
      raise "Primitive '#{property_hash[:first]}' does not exist!"
    end

    unless primitive_exists? primitive_base_name property_hash[:second]
      raise "Primitive '#{property_hash[:second]}' does not exist!"
    end

    colocation_structure = {}
    colocation_structure['id'] = property_hash[:name]
    colocation_structure['score'] = property_hash[:score]

    first_element_array = property_hash[:first].split ':'
    second_element_array = property_hash[:second].split ':'

    colocation_structure['rsc'] = second_element_array[0]
    colocation_structure['rsc-role'] = second_element_array[1] if second_element_array[1]
    colocation_structure['with-rsc'] = first_element_array[0]
    colocation_structure['with-rsc-role'] = first_element_array[1] if first_element_array[1]

    colocation_patch = xml_document
    colocation_element = xml_rsc_colocation colocation_structure
    raise "Could not create XML patch for '#{resource}'" unless colocation_element
    colocation_patch.add_element colocation_element

    if present?
      wait_for_constraint_update xml_pretty_format(colocation_patch.root), colocation_structure['id']
    else
      wait_for_constraint_create xml_pretty_format(colocation_patch.root), colocation_structure['id']
    end
    cluster_debug_report "#{resource} flush"
  end
end
