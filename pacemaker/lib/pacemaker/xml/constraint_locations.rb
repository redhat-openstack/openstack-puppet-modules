module Pacemaker
  # functions related to locations constraints
  # main structure "constraint_locations"
  module ConstraintLocations
    # construct the constraint unique name
    # from primitive's and node's names
    # @param primitive [String]
    # @param node [String]
    # @return [String]
    def service_location_name(primitive, node)
      "#{primitive}-on-#{node}"
    end

    # check if service location exists for this primitive on this node
    # @param primitive [String] the primitive's name
    # @param node [String] the node's name
    # @return [true,false]
    def service_location_exists?(primitive, node)
      id = service_location_name primitive, node
      constraint_location_exists? id
    end

    # add a location constraint to enable a service on a node
    # @param primitive [String] the primitive's name
    # @param node [String] the node's name
    # @param score [Numeric,String] score value
    def service_location_add(primitive, node, score = 100)
      location_structure = {
          'id' => service_location_name(primitive, node),
          'node' => node,
          'rsc' => primitive,
          'score' => score,
      }
      constraint_location_add location_structure
    end

    # remove the service location on this node
    # @param primitive [String] the primitive's name
    # @param node [String] the node's name
    def service_location_remove(primitive, node)
      id = service_location_name primitive, node
      constraint_location_remove id
    end

    # get location constraints and use mnemoization on the list
    # @return [Hash<String => Hash>]
    def constraint_locations
      return @locations_structure if @locations_structure
      @locations_structure = constraints 'rsc_location'
    end

    # add a location constraint
    # @param location_structure [Hash<String => String>] the location data structure
    def constraint_location_add(location_structure)
      location_patch = xml_document
      location_element = xml_rsc_location location_structure
      raise "Could not create XML patch from location '#{location_structure.inspect}'!" unless location_element
      location_patch.add_element location_element
      wait_for_constraint_create xml_pretty_format(location_patch.root), location_structure['id']
    end

    # remove a location constraint
    # @param id [String] the constraint id
    def constraint_location_remove(id)
      wait_for_constraint_remove "<rsc_location id='#{id}'/>\n", id
    end

    # check if locations constraint exists
    # @param id [String] the constraint id
    # @return [TrueClass,FalseClass]
    def constraint_location_exists?(id)
      constraint_locations.key? id
    end

    # generate rsc_location elements from data structure
    # @param data [Hash]
    # @return [REXML::Element]
    def xml_rsc_location(data)
      return unless data && data.is_a?(Hash)
      # create an element from the top level hash and skip 'rules' attribute
      # because if should be processed as children elements and useless 'type' attribute
      rsc_location_element = xml_element 'rsc_location', data, %w(rules type)

      # there are no rule elements
      return rsc_location_element unless data['rules'] && data['rules'].respond_to?(:each)

      # create a rule element with attributes and treat expressions as children elements
      sort_data(data['rules']).each do |rule|
        next unless rule.is_a? Hash
        rule_element = xml_element 'rule', rule, 'expressions'
        # add expression children elements to the rule element if the are present
        if rule['expressions'] && rule['expressions'].respond_to?(:each)
          sort_data(rule['expressions']).each do |expression|
            next unless expression.is_a? Hash
            expression_element = xml_element 'expression', expression
            rule_element.add_element expression_element
          end
        end
        rsc_location_element.add_element rule_element
      end
      rsc_location_element
    end
  end
end
