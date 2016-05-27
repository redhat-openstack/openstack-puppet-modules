module Pacemaker
  # this submodule contains "pcs" based function for operation default provider
  module PcsOperationDefault
    # @return [String]
    def pcs_operation_default_list
      pcs 'resource', 'op', 'defaults'
    rescue Puppet::ExecutionFailure
      ''
    end

    # @return [Hash]
    def pcs_operation_defaults
      pcs_list_to_hash pcs_operation_default_list
    end

    # @return [String,true,false,nil]
    def pcs_operation_default_value(name)
      pcs_operation_defaults.fetch name.to_s, nil
    end

    # @param name [String]
    # @param value [String,true,false]
    def pcs_operation_default_set(name, value)
      cmd = ['resource', 'op', 'defaults', "#{name}=#{value}"]
      retry_block { pcs_safe cmd }
    end

    # @param name [String]
    def pcs_operation_default_delete(name)
      cmd = ['resource', 'op', 'defaults', "#{name}="]
      retry_block { pcs_safe cmd }
    end

    # @param name [String]
    # @return [true,false]
    def pcs_operation_default_defined?(name)
      pcs_operation_defaults.key? name.to_s
    end
  end
end
