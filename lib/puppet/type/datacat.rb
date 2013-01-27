Puppet::Type.newtype(:datacat) do
    newparam(:path, :namevar => true) do
    end

    newproperty(:template) do
    end

    autorequire(:datacat_fragment) do
        catalog.resources.find_all { |r|
            r.is_a?(Puppet::Type.type(:datacat_fragment)) and r[:target] == self[:path]
        }
    end

    def self.merge_data(path, data)
        debug "merge_data #{path} #{data}"
        @@data ||= {}
        @@data[path] ||= {}
        @@data[path].merge!(data)
        debug @@data.inspect
    end
end
