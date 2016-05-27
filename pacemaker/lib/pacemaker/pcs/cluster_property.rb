module Pacemaker
  # this submodule contains "pcs" based function for cluster property provider
  module PcsClusterProperty
    # @return [String]
    def pcs_cluster_properties_list
      pcs 'property', 'list'
    rescue Puppet::ExecutionFailure
      ''
    end

    # @return [Hash]
    def pcs_cluster_properties
      pcs_list_to_hash pcs_cluster_properties_list
    end

    # @return [String,true,false,nil]
    def pcs_cluster_property_value(name)
      pcs_cluster_properties.fetch name.to_s, nil
    end

    # @param name [String]
    # @param value [String,true,false]
    def pcs_cluster_property_set(name, value)
      cmd = ['property', 'set', "#{name}=#{value}"]
      retry_block { pcs_safe cmd }
    end

    # @param name [String]
    def pcs_cluster_property_delete(name)
      cmd = ['property', 'unset', name]
      retry_block { pcs_safe cmd }
    end

    # @param name [String]
    # @return [true,false]
    def pcs_cluster_property_defined?(name)
      pcs_cluster_properties.key? name.to_s
    end
  end
end
