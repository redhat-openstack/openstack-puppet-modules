module Pacemaker
  # functions that are used to generate XML documents and create XML patches
  module Xml
    # create a new xml document
    # @param path [String,Array<String>] create this sequence of path elements
    # @param root [REXML::Document] use existing element as a root instead of creating a new one
    # @return [REXML::Element] element point to the last path component
    # use .root to get the document root
    def xml_document(path = [], root = nil)
      root = REXML::Document.new unless root
      element = root
      path = Array(path) unless path.is_a? Array
      path.each do |component|
        element = element.add_element component
      end
      element
    end

    # convert hash to xml element
    # @param tag [String] what xml tag to create
    # @param hash [Hash] attributes data structure
    # @param skip_attributes [String,Array<String>] skip these hash keys
    # @return [REXML::Element]
    def xml_element(tag, hash, skip_attributes = nil)
      return unless hash.is_a? Hash
      element = REXML::Element.new tag.to_s
      hash.each do |attribute, value|
        attribute = attribute.to_s
        # skip attributes that were specified to be skipped
        next if skip_attributes == attribute ||
            (skip_attributes.respond_to?(:include?) && skip_attributes.include?(attribute))
        # skip array and hash values. add only scalar ones
        next if value.is_a?(Array) || value.is_a?(Hash)
        element.add_attribute attribute, value
      end
      element
    end

    # output xml element as the actual xml text with indentation
    # @param element [REXML::Element]
    # @return [String]
    def xml_pretty_format(element)
      return unless element.is_a? REXML::Element
      formatter = REXML::Formatters::Pretty.new
      formatter.compact = true
      xml = ''
      formatter.write element, xml
      xml + "\n"
    end
  end
end

# external REXML module patching
module REXML
  # make REXML's attributes to be sorted by their name
  # when iterating through them instead of randomly placing them each time
  # it's required to generate stable XML texts for unit testing
  class Attributes
    def each_value # :yields: attribute
      keys.sort.each do |key|
        yield fetch key
      end
    end
  end
end
