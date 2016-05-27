require_relative '../pacemaker_xml'

Puppet::Type.type(:pacemaker_nodes).provide(:xml, parent: Puppet::Provider::PacemakerXML) do
  commands cmapctl: '/usr/sbin/corosync-cmapctl'
  commands cibadmin: '/usr/sbin/cibadmin'
  commands crm_node: '/usr/sbin/crm_node'
  commands crm_attribute: '/usr/sbin/crm_attribute'

  def cmapctl_nodelist
    cmapctl '-b', 'nodelist.node'
  end

  def nodes_data
    return {} unless @resource[:nodes].is_a? Hash
    @resource[:nodes]
  end

  # retrieve the current Corosync nodes
  # the node number to match the "id" and the ring address lines
  # @return <Hash>
  def corosync_nodes_structure
    return @corosync_nodes_structure if @corosync_nodes_structure
    nodes = {}
    cmapctl_nodelist.split("\n").each do |line|
      if line =~ /^nodelist\.node\.(\d+)\.nodeid\s+\(u32\)\s+=\s+(\d+)/
        # this is the 'id' line
        node_number = Regexp.last_match(1)
        node_id = Regexp.last_match(2)
        nodes[node_number] = {} unless nodes[node_number]
        nodes[node_number]['id'] = node_id
        nodes[node_number]['number'] = node_number
      end
      if line =~ /^nodelist\.node\.(\d+)\.ring(\d+)_addr\s+\(str\)\s+=\s+(\S+)/
        node_number = Regexp.last_match(1)
        ring_number = Regexp.last_match(2)
        node_ip_addr = Regexp.last_match(3)
        nodes[node_number] = {} unless nodes[node_number]
        key = "ring#{ring_number}"
        nodes[node_number][key] = node_ip_addr
      end
    end
    @corosync_nodes_structure = {}
    nodes.values.each do |node|
      id = node['id']
      next unless id
      @corosync_nodes_structure[id] = node
    end
    @corosync_nodes_structure
  end

  # ids and name of current Pacemaker nodes
  # @return <Hash>
  def pacemaker_nodes_structure
    @pacemaker_nodes_structure = {}
    nodes.each do |name, node|
      id = node['id']
      next unless name && id
      @pacemaker_nodes_structure.store id, name
    end
    @pacemaker_nodes_structure
  end

  def pacemaker_nodes_reset
    @corosync_nodes_structure = nil
    @pacemaker_nodes_structure = nil
    @resource_nodes_structure = nil
    @node_name = nil
  end

  def next_corosync_node_number
    number = corosync_nodes_structure.inject(0) do |max, node|
      number = node.last['number'].to_i
      max = number if number > max
      max
    end
    number += 1
    number.to_s
  end

  def remove_pacemaker_node_record(node_name)
    cibadmin_safe '--delete', '--scope', 'nodes', '--xml-text', "<node uname='#{node_name}'/>"
  end

  def remove_pacemaker_node_state(node_name)
    cibadmin_safe '--delete', '--scope', 'status', '--xml-text', "<node_state uname='#{node_name}'/>"
  end

  def remove_location_constraints(node_name)
    cibadmin_safe '--delete', '--scope', 'constraints', '--xml-text', "<rsc_location node='#{node_name}'/>"
  end

  def remove_corosync_node_record(node_number)
    cmapctl_safe '-D', "nodelist.node.#{node_number}"
  rescue => e
    debug "Failed: #{e.message}"
  end

  def add_corosync_node_record(node_number, node_id, ring0 = nil, ring1 = nil)
    cmapctl_safe '-s', "nodelist.node.#{node_number}.nodeid", 'u32', node_id
    cmapctl_safe '-s', "nodelist.node.#{node_number}.ring0_addr", 'str', ring0 if ring0
    cmapctl_safe '-s', "nodelist.node.#{node_number}.ring1_addr", 'str', ring1 if ring1
  end

  def remove_pacemaker_node(node_name)
    debug "Remove the pacemaker node: '#{node_name}'"
    remove_pacemaker_node_record node_name
    remove_pacemaker_node_state node_name
    remove_location_constraints node_name
    pacemaker_nodes_reset
  end

  def remove_corosync_node(node_id)
    debug "Remove the corosync node: '#{node_id}'"
    node_number = corosync_nodes_structure.fetch(node_id, {}).fetch('number')
    raise "Could not get the node_number of the node_id: '#{node_id}'!" unless node_number
    remove_corosync_node_record node_number
    pacemaker_nodes_reset
  end

  def add_corosync_node(node_id)
    debug "Add corosync node: '#{node_id}'"
    node_number = next_corosync_node_number
    raise "Could not find node_id: '#{node_id}' in the resource data!" unless nodes_data[node_id].is_a? Hash
    ring0 = nodes_data[node_id]['ring0']
    ring1 = nodes_data[node_id]['ring1']
    add_corosync_node_record node_number, node_id, ring0, ring1
    pacemaker_nodes_reset
  end

end
