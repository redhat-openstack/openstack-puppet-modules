module Pacemaker
  # functions related to the cluster nodes
  # main structure "nodes" with node's names and ids
  module Nodes
    # get nodes CIB section
    # @return [REXML::Element] at /cib/configuration/nodes
    def cib_section_nodes
      REXML::XPath.match cib, '/cib/configuration/nodes/*'
    end

    # hostname of the current node
    # @return [String]
    def node_name
      return @node_name if @node_name
      @node_name = crm_node('-n').chomp.strip
    end

    alias hostname node_name

    # the nodes structure
    # uname => id
    # @return [Hash<String => Hash>]
    def nodes
      return @nodes_structure if @nodes_structure
      @nodes_structure = {}
      cib_section_nodes.each do |node_block|
        node = attributes_to_hash node_block
        next unless node['id'] && node['uname']
        @nodes_structure.store node['uname'], node
      end
      @nodes_structure
    end

    # the name of the current DC node
    # @return [String,nil]
    def dc_name
      dc_node_id = dc
      return unless dc_node_id
      nodes.each do |node, attrs|
        next unless attrs['id'] == dc_node_id
        return node
      end
      nil
    end

  end
end
