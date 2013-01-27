Puppet::Type.type(:datacat_fragment).provide(:default) do
    mk_resource_methods

    def flush
        debug "flushing"
        datacat_class = Puppet::Type.type(:datacat)
        datacat_class.merge_data(@resource[:target], @resource[:data])
    end
end
