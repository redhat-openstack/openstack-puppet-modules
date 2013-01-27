Puppet::Type.type(:datacat).provide(:datacat) do
    mk_resource_methods

    def flush
        debug "flushing"

        if @@data
            debug @resource[:path]
            data = @@data[@resource[:path]]
            debug "Collected #{data.inspect}"
        else
            debug "no data exported"
        end
    end
end
