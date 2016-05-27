module Pacemaker
  # functions related to colocations constraints
  # main structure "constraint_colocations"
  module ConstraintColocations
    # get colocation constraints and use mnemoization on the list
    # @return [Hash<String => Hash>]
    def constraint_colocations
      return @colocations_structure if @colocations_structure
      @colocations_structure = constraints 'rsc_colocation'
    end

    # check if colocation constraint exists
    # @param id [String] the constraint id
    # @return [TrueClass,FalseClass]
    def constraint_colocation_exists?(id)
      constraint_colocations.key? id
    end

    # add a colocation constraint
    # @param colocation_structure [Hash<String => String>] the location data structure
    def constraint_colocation_add(colocation_structure)
      colocation_patch = xml_document
      colocation_element = xml_rsc_colocation colocation_structure
      raise "Could not create XML patch from colocation '#{colocation_structure.inspect}'!" unless colocation_element
      colocation_patch.add_element colocation_element
      wait_for_constraint_create xml_pretty_format(colocation_patch.root), colocation_structure['id']
    end

    # remove a colocation constraint
    # @param id [String] the constraint id
    def constraint_colocation_remove(id)
      wait_for_constraint_remove "<rsc_colocation id='#{id}'/>\n", id
    end

    # generate rsc_colocation elements from data structure
    # @param data [Hash]
    # @return [REXML::Element]
    def xml_rsc_colocation(data)
      return unless data && data.is_a?(Hash)
      xml_element 'rsc_colocation', data, 'type'
    end
  end
end
