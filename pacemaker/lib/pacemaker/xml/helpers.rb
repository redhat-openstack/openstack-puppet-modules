module Pacemaker
  # misc helper methods used in other submodules
  module Helpers
    # convert elements's attributes to hash
    # @param element [REXML::Element]
    # @return [Hash<String => String>]
    def attributes_to_hash(element, hash = {})
      element.attributes.each do |a, v|
        next if a == '__crm_diff_marker__'
        hash.store a.to_s, v.to_s
      end
      hash
    end

    # convert element's children to hash
    # of their attributes using key and hash key
    # @param element [REXML::Element]
    # @param key <String> use this attribute as hash key
    # @param tag <String> get only this type of children
    # @return [Hash<String => String>]
    def children_elements_to_hash(element, key, tag = nil)
      return unless element.is_a? REXML::Element
      elements = {}
      children = element.get_elements tag
      return elements unless children
      children.each do |child|
        child_structure = attributes_to_hash child
        name = child_structure[key]
        next unless name
        elements.store name, child_structure
      end
      elements
    end

    # convert element's children to array of their attributes
    # @param element [REXML::Element]
    # @param tag [String] get only this type of children
    # @return [Array<Hash>]
    def children_elements_to_array(element, tag = nil)
      return unless element.is_a? REXML::Element
      elements = []
      children = element.get_elements tag
      return elements unless children
      children.each do |child|
        child_structure = attributes_to_hash child
        next unless child_structure['id']
        elements << child_structure
      end
      elements
    end

    # copy value from one hash_like structure to another
    # if the value is present
    # @param from[Hash]
    # @param from_key [String,Symbol]
    # @param to [Hash]
    # @param to_key [String,Symbol,NilClass]
    def copy_value(from, from_key, to, to_key = nil)
      value = from[from_key]
      return value unless value
      to_key = from_key unless to_key
      to[to_key] = value
      value
    end

    # sort hash of hashes into an array of hashes
    # by one of the subhash's attributes
    # @param data [Hash<String => Hash>]
    # @param key [String]
    # @return [Array<Hash>]
    def sort_data(data, key = 'id')
      data = data.values if data.is_a? Hash
      data.sort do |x, y|
        break 0 unless x[key] && y[key]
        x[key] <=> y[key]
      end
    end

    # return service status value expected by Puppet
    # puppet wants :running or :stopped symbol
    # @param primitive [String] primitive id
    # @param node [String] on this node if given
    # @return [:running,:stopped]
    def get_primitive_puppet_status(primitive, node = nil)
      if primitive_is_running? primitive, node
        :running
      else
        :stopped
      end
    end

    # return service enabled status value expected by Puppet
    # puppet wants :true or :false symbols
    # @param primitive [String]
    # @return [:true,:false]
    def get_primitive_puppet_enable(primitive)
      if primitive_is_managed? primitive
        :true
      else
        :false
      end
    end

    # import the library representation of the attributes structure
    # to the Puppet one
    def import_attributes_structure(attributes)
      return unless attributes.respond_to? :each
      hash = {}
      attributes.each do |attribute|
        if attribute.is_a?(Array) && attribute.length == 2
          attribute = attribute[1]
        end
        next unless attribute['name'] && attribute['value']
        hash.store attribute['name'], attribute['value']
      end
      hash
    end

    # export the Puppet representation of attributes
    # to the library one
    # @param hash [Hash] attributes (name => value)
    # @param attributes_id_tag [String] attributes name for id naming
    # @return [Hash,NilClass]
    def export_attributes_structure(hash, attributes_id_tag)
      return unless hash.is_a? Hash
      attributes = {}
      hash.each do |attribute_name, attribute_value|
        id_components = [resource[:name], attributes_id_tag, attribute_name]
        id_components.reject!(&:nil?)
        attribute_structure = {}
        attribute_structure['id'] = id_components.join '-'
        attribute_structure['name'] = attribute_name
        attribute_structure['value'] = attribute_value
        attributes.store attribute_name, attribute_structure
      end
      attributes
    end
  end
end
