module Pacemaker
  # this submodule contains "pcs" based function for resource default provider
  module PcsResourceDefault
    # @return [String]
    def pcs_resource_default_list
      pcs 'resource', 'defaults'
    rescue Puppet::ExecutionFailure
      ''
    end

    # @return [Hash]
    def pcs_resource_defaults
      pcs_list_to_hash pcs_resource_default_list
    end

    # @return [String,true,false,nil]
    def pcs_resource_default_value(name)
      pcs_resource_defaults.fetch name.to_s, nil
    end

    # @param name [String]
    # @param value [String,true,false]
    def pcs_resource_default_set(name, value)
      cmd = ['resource', 'defaults', "#{name}=#{value}"]
      retry_block { pcs_safe cmd }
    end

    # @param name [String]
    def pcs_resource_default_delete(name)
      cmd = ['resource', 'defaults', "#{name}="]
      retry_block { pcs_safe cmd }
    end

    # @param name [String]
    # @return [true,false]
    def pcs_resource_default_defined?(name)
      pcs_resource_defaults.key? name.to_s
    end
  end
end
