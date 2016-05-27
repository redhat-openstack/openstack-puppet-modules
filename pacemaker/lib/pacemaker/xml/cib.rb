# the Pacemaker module contains many submodules separated
# by the preformed functions. They are later merged
# together in the 'provided' file
module Pacemaker
  # this submodule contains the basic functions
  # for low-level actions with CIB data
  module Cib
    # get the raw CIB from Pacemaker
    # @return [String] cib xml data
    def raw_cib
      raw_cib = cibadmin '-Q'
      raise 'Could not dump CIB XML!' if !raw_cib || raw_cib == ''
      raw_cib
    end

    # REXML::Document of the CIB data
    # @return [REXML::Document] at '/'
    def cib
      return @cib if @cib
      @cib = REXML::Document.new(raw_cib)
    end

    # insert a new cib xml data instead of retrieving it
    # can be used either for prefetching or for debugging
    # @param cib [String,REXML::Document] CIB XML text or element
    def cib=(cib)
      @cib = if cib.is_a? REXML::Document
               cib
             else
               REXML::Document.new(cib)
             end
    end

    # check id the CIB is retrieved and memorized
    # @return [TrueClass,FalseClass]
    def cib?
      !@cib.nil?
    end

    # add a new XML element to CIB
    # @param xml [String, REXML::Element] XML block to add
    # @param scope [String] XML root scope
    def cibadmin_create(xml, scope = nil)
      xml = xml_pretty_format xml if xml.is_a? REXML::Element
      options = %w(--force  --sync-call --create)
      options += ['--scope', scope.to_s] if scope
      cibadmin_safe options, '--xml-text', xml.to_s
    end

    # delete the XML element to CIB
    # @param xml [String, REXML::Element] XML block to delete
    # @param scope [String] XML root scope
    def cibadmin_delete(xml, scope = nil)
      xml = xml_pretty_format xml if xml.is_a? REXML::Element
      options = %w(--force  --sync-call --delete)
      options += ['--scope', scope.to_s] if scope
      cibadmin_safe options, '--xml-text', xml.to_s
    end

    # modify the XML element
    # @param xml [String, REXML::Element] XML element to modify
    # @param scope [String] XML root scope
    def cibadmin_modify(xml, scope = nil)
      xml = xml_pretty_format xml if xml.is_a? REXML::Element
      options = %w(--force  --sync-call --modify)
      options += ['--scope', scope.to_s] if scope
      cibadmin_safe options, '--xml-text', xml.to_s
    end

    # replace the XML element
    # @param xml [String, REXML::Element] XML element to replace
    # @param scope [String] XML root scope
    def cibadmin_replace(xml, scope = nil)
      xml = xml_pretty_format xml if xml.is_a? REXML::Element
      options = %w(--force  --sync-call --replace)
      options += ['--scope', scope.to_s] if scope
      cibadmin_safe options, '--xml-text', xml.to_s
    end

    # get the name of the DC (Designated Controller) node
    # used to determine if the cluster have elected one and is ready
    # @return [String, nil]
    def dc
      cib_element = cib.elements['/cib']
      return unless cib_element
      dc_node_id = cib_element.attribute('dc-uuid')
      return unless dc_node_id
      return if dc_node_id == 'NONE'
      dc_node_id.to_s
    end

    # get the dc_version string from the CIB configuration
    # used to determine that the cluster have finished forming a correct cib structure
    # uses an independent command call because CIB may not be ready yet
    # @return [String, nil]
    def dc_version
      dc_version = crm_attribute '-q', '--type', 'crm_config', '--query', '--name', 'dc-version'
      return if dc_version.empty?
      dc_version
    end

    # reset all mnemoization variables
    # to force pacemaker to reload all the data structures
    # @param comment [String] log file comment tag to trace calls
    def cib_reset(comment = nil)
      message = 'Call: cib_reset'
      message += " (#{comment})" if comment
      debug message

      @cib = nil

      @primitives_structure = nil
      @locations_structure = nil
      @colocations_structure = nil
      @orders_structure = nil
      @node_status_structure = nil
      @cluster_properties_structure = nil
      @nodes_structure = nil
      @resource_defaults_structure = nil
      @operation_defaults_structure = nil
    end
  end
end
