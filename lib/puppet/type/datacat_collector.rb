Puppet::Type.newtype(:datacat_collector) do
    newparam(:path, :namevar => true) do
    end

    newproperty(:template) do
    end

    newparam(:template_body) do
    end

    autorequire(:datacat_fragment) do
        catalog.resources.find_all { |r|
            r.is_a?(Puppet::Type.type(:datacat_fragment)) and r[:target] == self[:path]
        }
    end
end


class Puppet::Type::Datacat
    @@data = {}

    def self.set_data(path, data)
        @@data[path] ||= {}
        @@data[path].merge!(data)
    end

    def self.get_data(path)
        @@data[path]
    end
end
