Puppet::Type.newtype(:datacat) do
    newparam(:path, :namevar => true) do
    end

    newparam(:template) do
    end

    autorequire(:datacat_fragment) do
        catalog.resources.find_all { |r|
            r.is_a?(Puppet::Type.type(:datacat_fragment)) and r[:target] == self[:path]
        }
    end
end
