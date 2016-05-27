module Pacemaker
  # functions related to constraints (order, location, colocation)
  # main structure "constraints"
  # this structure is used by other specific location colocation and order
  # submodules to form their data structures
  module Constraints
    # get all 'rsc_location', 'rsc_order' and 'rsc_colocation' sections from CIB
    # @return [Array<REXML::Element>] at /cib/configuration/constraints/*
    def cib_section_constraints
      REXML::XPath.match cib, '//constraints/*'
    end

    # get all rule elements from the constraint element
    # @return [Array<REXML::Element>] at /cib/configuration/constraints/*/rule
    def cib_section_constraint_rules(constraint)
      return unless constraint.is_a? REXML::Element
      REXML::XPath.match constraint, 'rule'
    end

    # parse constraint rule elements to the rule structure
    # @param element [REXML::Element]
    # @return [Hash<String => Hash>]
    def decode_constraint_rules(element)
      rules = cib_section_constraint_rules element
      return [] unless rules.any?
      rules_array = []
      rules.each do |rule|
        rule_structure = attributes_to_hash rule
        next unless rule_structure['id']
        rule_expressions = children_elements_to_array rule, 'expression'
        rule_structure.store 'expressions', rule_expressions if rule_expressions
        rules_array << rule_structure
      end
      rules_array.sort_by { |rule| rule['id'] }
    end

    # decode a single constraint element to the data structure
    # @param element [REXML::Element]
    # @return [Hash<String => String>]
    def decode_constraint(element)
      return unless element.is_a? REXML::Element
      return unless element.attributes['id']
      return unless element.name

      constraint_structure = attributes_to_hash element
      constraint_structure.store 'type', element.name

      rules = decode_constraint_rules element
      constraint_structure.store 'rules', rules if rules.any?
      constraint_structure
    end

    # constraints found in the CIB
    # filter them by the provided tag name
    # @param type [String] filter this location type
    # @return [Hash<String => Hash>]
    def constraints(type = nil)
      constraints = {}
      cib_section_constraints.each do |constraint|
        constraint_structure = decode_constraint constraint
        next unless constraint_structure
        next unless constraint_structure['id']
        next if type && !(constraint_structure['type'] == type)
        constraint_structure.delete 'type'
        constraints.store constraint_structure['id'], constraint_structure
      end
      constraints
    end

    # check if a constraint exists
    # @param id [String] the constraint id
    # @return [TrueClass,FalseClass]
    def constraint_exists?(id)
      constraints.key? id
    end
  end
end
