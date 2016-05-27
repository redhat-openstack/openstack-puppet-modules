require 'set'

module Pacemaker
  # contains functions that can be included to the pacemaker types
  module Type
    # output IS and SHOULD values for debugging
    # @param is [Object] the current value of the parameter
    # @param should [Object] the catalog value of the parameter
    # @param tag [String] log tag comment to trace calls
    def insync_debug(is, should, tag = nil)
      debug "insync?: #{tag}" if tag
      debug "IS: #{is.inspect} #{is.class}"
      debug "SH: #{should.inspect} #{should.class}"
    end

    # return inspected data structure, used in should_to_s and is_to_s functions
    # @param data [Object]
    # @return [String]
    def inspect_to_s(data)
      data.inspect
    end

    # convert data structure's keys and values to strings
    # @param data [Object]
    # @return [Object]
    def stringify_data(data)
      if data.is_a? Hash
        new_data = {}
        data.each do |key, value|
          new_data.store stringify_data(key), stringify_data(value)
        end
        data.clear
        data.merge! new_data
      elsif data.is_a? Array
        data.map! do |element|
          stringify_data element
        end
      else
        data.to_s
      end
    end

    # modify provided operations data
    # @param [Hash,Array] operations_input parameter value from catalog
    def munge_operations(operations_input)
      operations_input = [operations_input] unless operations_input.is_a? Array
      operations = Set.new
      operations_input.each do |operation|
        # operations are an array of sets
        if operation.is_a? Set
          operations.merge operation
          next
        end
        # # operations were provided as an array of hashes
        if operation.is_a? Hash and operation['name']
          munge_operation operation
          operations.add operation
          next
        end
        # operations were provided as a hash of hashes
        operation.each do |operation_name, operation_data|
          next unless operation_data.is_a? Hash
          operation = {}
          if operation_name.include? ':'
            operation_name_array = operation_name.split(':')
            operation_name = operation_name_array[0]
            if not operation_data['role'] and operation_name_array[1]
              operation_data['role'] = operation_name_array[1]
            end
          end
          operation['name'] = operation_name
          operation.merge! operation_data
          munge_operation operation
          operations.add operation if operation.any?
        end
      end
      operations
    end

    # munge a single operations hash
    # @param [Hash] operation
    def munge_operation(operation)
      return unless operation.is_a? Hash
      operation['name'] = 'monitor' unless operation['name']
      operation['interval'] = '0' unless operation['name'] == 'monitor'
      operation['interval'] = '0' unless operation['interval']
      operation['role'].capitalize! if operation['role']
      operation
    end

    # compare meta_attribute hashes excluding status meta attributes
    # @param is [Hash]
    # @param should [Hash]
    # @return [TrueClass,FalseClass]
    def compare_meta_attributes(is, should)
      return unless is.is_a?(Hash) && should.is_a?(Hash)
      is_without_state = is.reject do |k, _v|
        pacemaker_options[:status_meta_attributes].include? k.to_s
      end
      should_without_state = should.reject do |k, _v|
        pacemaker_options[:status_meta_attributes].include? k.to_s
      end
      result = is_without_state == should_without_state
      debug "compare_meta_attributes: #{result}"
      result
    end

    # sort operations array before insync?
    # to make different order and same data arrays equal
    # @param is [Array]
    # @param should [Array]
    # @return [TrueClass,FalseClass]
    def compare_operations(is, should)
      is = is.first if is.is_a? Array
      should = should.first if should.is_a? Array
      result = (is == should)
      debug "compare_operations: #{result}"
      result
    end

    # remove status related meta attributes
    # from the meta attributes hash
    # @param attributes_from [Hash]
    # @return [Hash]
    def munge_meta_attributes(attributes_from)
      attributes_to = {}
      attributes_from.each do |name, parameters|
        next if pacemaker_options[:status_meta_attributes].include? name
        attributes_to.store name, parameters
      end
      attributes_to
    end

    # normalize a single location rule
    # @param rule [Hash] rule structure
    # @param rule_number [Integer] rule index number
    # @param title [String] constraint name
    # @return [Hash] normalized rule structure
    def munge_rule(rule, rule_number, title)
      rule['id'] = "#{title}-rule-#{rule_number}" unless rule['id']
      rule['boolean-op'] = 'or' unless rule['boolean-op']
      rule['score'].gsub! 'inf', 'INFINITY' if rule['score']
      if rule['expressions']
        unless rule['expressions'].is_a? Array
          expressions_array = []
          expressions_array << rule['expressions']
          rule['expressions'] = expressions_array
        end
        expression_number = 0
        rule['expressions'].each do |expression|
          unless expression['id']
            expression['id'] = "#{title}-rule-#{rule_number}-expression-#{expression_number}"
          end
          expression_number += 1
        end
      end
      rule
    end

    # remove "-clone" or "-master" suffix
    # and "role" suffix (:Master, :Slave) from a primitive's name
    # @param primitive [String]
    # @return [String]
    def primitive_base_name(primitive)
      primitive = primitive.split(':').first
      primitive.gsub(/-clone$|-master$/, '')
    end
  end
end
