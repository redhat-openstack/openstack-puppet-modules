module Pacemaker
  # functions related to the resource defaults
  # main structure "resource_defaults"
  module ResourceDefault
    # get resource defaults CIB section
    # @return [REXML::Element]
    def cib_section_resource_defaults
      REXML::XPath.match(cib, '/cib/configuration/rsc_defaults/meta_attributes').first
    end

    # the main 'resource_defaults' structure
    # contains defaults operations and their values
    # @return [Hash]
    def resource_defaults
      return @resource_defaults_structure if @resource_defaults_structure
      @resource_defaults_structure = children_elements_to_hash cib_section_resource_defaults, 'name'
      @resource_defaults_structure = {} unless @resource_defaults_structure
      @resource_defaults_structure
    end

    # extract a single resource default attribute value
    # returns nil if it have not been set
    # @param attribute_name [String]
    # @return [String, nil]
    def resource_default_value(attribute_name)
      return unless resource_default_defined? attribute_name
      resource_defaults[attribute_name]['value']
    end

    # set a single resource default value
    # @param attribute_name [String]
    # @param attribute_value [String]
    def resource_default_set(attribute_name, attribute_value)
      options = ['--quiet', '--type', 'rsc_defaults', '--attr-name', attribute_name]
      options += ['--attr-value', attribute_value]
      retry_block { crm_attribute_safe options }
    end

    # remove a defined resource default attribute
    # @param attribute_name [String]
    def resource_default_delete(attribute_name)
      options = ['--quiet', '--type', 'rsc_defaults', '--attr-name', attribute_name]
      options += ['--delete-attr']
      retry_block { crm_attribute_safe options }
    end

    # check if this resource default attribute have been defined
    # @param attribute_name [String]
    # @return [true,false]
    def resource_default_defined?(attribute_name)
      return false unless resource_defaults.key? attribute_name
      return false unless resource_defaults[attribute_name].is_a?(Hash) && resource_defaults[attribute_name]['value']
      true
    end
  end
end
