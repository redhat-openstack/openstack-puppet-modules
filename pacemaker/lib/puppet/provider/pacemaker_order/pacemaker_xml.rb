require_relative '../pacemaker_xml'

Puppet::Type.type(:pacemaker_order).provide(:xml, parent: Puppet::Provider::PacemakerXML) do
  desc <<-eof
Specific provider for a rather specific type since I currently have no plan to
abstract corosync/pacemaker vs. keepalived. This provider will check the state
of current primitive start orders on the system; add, delete, or adjust various
aspects.
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
    proxy_instance.constraint_orders.map do |title, data|
      parameters = {}
      debug "Prefetch constraint_order: #{title}"
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
  # @param data [Hash] extracted order data
  # will extract the current order data unless a value is provided
  # @param target_structure [Hash] copy data to this structure
  # defaults to the property_hash of this provider
  def retrieve_data(data = nil, target_structure = property_hash)
    data = constraint_orders.fetch resource[:name], {} unless data
    target_structure[:name] = data['id'] if data['id']
    target_structure[:ensure] = :present
    target_structure[:first] = data['first'] if data['first']
    target_structure[:second] = data['then'] if data['then']
    target_structure[:first_action] = data['first-action'].downcase if data['first-action']
    target_structure[:second_action] = data['then-action'].downcase if data['then-action']
    target_structure[:score] = data['score'] if data['score']
    target_structure[:kind] = data['kind'].downcase if data['kind']
    target_structure[:symmetrical] = data['symmetrical'].downcase if data['symmetrical']
    target_structure[:require_all] = data['require-all'].downcase if data['require-all']
  end

  def exists?
    debug 'Call: exists?'
    out = constraint_order_exists? resource[:name]
    retrieve_data
    debug "Return: #{out}"
    out
  end

  # check if the order ensure is set to present
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
        first_action: resource[:first_action],
        second_action: resource[:second_action],
        score: resource[:score],
        kind: resource[:kind],
        symmetrical: resource[:symmetrical],
        require_all: resource[:require_all],
    }
  end

  # Unlike create we actually immediately delete the item.
  def destroy
    debug 'Call: destroy'
    constraint_order_remove resource[:name]
    property_hash.clear
    cluster_debug_report "#{resource} destroy"
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

  def first_action
    if property_hash[:first_action].respond_to? :to_sym
      property_hash[:first_action].to_sym
    else
      property_hash[:first_action]
    end
  end

  def second_action
    if property_hash[:second_action].respond_to? :to_sym
      property_hash[:second_action].to_sym
    else
      property_hash[:second_action]
    end
  end

  def score
    property_hash[:score]
  end

  def kind
    if property_hash[:kind].respond_to? :to_sym
      property_hash[:kind].to_sym
    else
      property_hash[:kind]
    end
  end

  def symmetrical
    property_hash[:symmetrical]
  end

  def require_all
    property_hash[:require_all]
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

  def first_action=(should)
    property_hash[:first_action] = should
  end

  def second_action=(should)
    property_hash[:second_action] = should
  end

  def score=(should)
    property_hash[:score] = should
  end

  def kind=(should)
    property_hash[:kind] = should
  end

  def symmetrical=(should)
    property_hash[:symmetrical] = should
  end

  def require_all=(should)
    property_hash[:require_all] = should
  end

  # Flush is triggered on anything that has been detected as being
  # modified in the property_hash.  It generates a temporary file with
  # the updates that need to be made.  The temporary file is then used
  # as stdin for the crm command.
  def flush
    debug 'Call: flush'
    return unless property_hash && property_hash.any?

    unless primitive_exists? primitive_base_name property_hash[:first]
      raise "Primitive '#{property_hash[:first]}' does not exist!"
    end

    unless primitive_exists? primitive_base_name property_hash[:second]
      raise "Primitive '#{property_hash[:second]}' does not exist!"
    end

    unless property_hash[:name] && property_hash[:first] && property_hash[:second]
      raise 'Data does not contain all the required fields!'
    end

    order_structure = {}
    order_structure['id'] = name
    order_structure['first'] = first
    order_structure['then'] = second
    order_structure['first-action'] = first_action.to_s if first_action
    order_structure['then-action'] = second_action.to_s if second_action
    order_structure['score'] = score.to_s if score
    order_structure['kind'] = kind.to_s.capitalize if kind
    order_structure['symmetrical'] = symmetrical.to_s unless symmetrical.nil?
    order_structure['require-all'] = require_all.to_s unless require_all.nil?

    order_patch = xml_document
    order_element = xml_rsc_order order_structure
    raise "Could not create XML patch for '#{resource}'" unless order_element
    order_patch.add_element order_element

    if present?
      wait_for_constraint_update xml_pretty_format(order_patch.root), order_structure['id']
    else
      wait_for_constraint_create xml_pretty_format(order_patch.root), order_structure['id']
    end
    cluster_debug_report "#{resource} flush"
  end
end
