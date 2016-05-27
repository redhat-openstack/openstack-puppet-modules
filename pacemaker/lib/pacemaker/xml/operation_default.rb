module Pacemaker
  # functions related to the operation defaults
  # main structure "operation_defaults"
  module OperationDefault
    # get operation defaults CIB section
    # @return [REXML::Element]
    def cib_section_operation_defaults
      REXML::XPath.match(cib, '/cib/configuration/op_defaults/meta_attributes').first
    end

    # the main 'operation_defaults' structure
    # contains defaults operations and their values
    # @return [Hash]
    def operation_defaults
      return @operation_defaults_structure if @operation_defaults_structure
      @operation_defaults_structure = children_elements_to_hash cib_section_operation_defaults, 'name'
      @operation_defaults_structure = {} unless @operation_defaults_structure
      @operation_defaults_structure
    end

    # extract a single operation default attribute value
    # returns nil if it have not been set
    # @param attribute_name [String]
    # @return [String, nil]
    def operation_default_value(attribute_name)
      return unless operation_default_defined? attribute_name
      operation_defaults[attribute_name]['value']
    end

    # set a single operation default value
    # @param attribute_name [String]
    # @param attribute_value [String]
    def operation_default_set(attribute_name, attribute_value)
      options = ['--quiet', '--type', 'op_defaults', '--attr-name', attribute_name]
      options += ['--attr-value', attribute_value]
      retry_block { crm_attribute_safe options }
    end

    # remove a defined operation default attribute
    # @param attribute_name [String]
    def operation_default_delete(attribute_name)
      options = ['--quiet', '--type', 'op_defaults', '--attr-name', attribute_name]
      options += ['--delete-attr']
      retry_block { crm_attribute_safe options }
    end

    # check if this operation default attribute have been defined
    # @param attribute_name [String]
    # @return [true,false]
    def operation_default_defined?(attribute_name)
      return false unless operation_defaults.key? attribute_name
      return false unless operation_defaults[attribute_name].is_a?(Hash) && operation_defaults[attribute_name]['value']
      true
    end
  end
end
