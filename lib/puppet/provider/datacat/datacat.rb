Puppet::Type.type(:datacat).provide(:datacat) do
    mk_resource_methods

    def flush
        debug "flushing"

        data = Puppet::Type::Datacat::Common.get_data(@resource[:path])
        if data
            debug "Collected #{data.inspect}"
        else
            debug "no data exported"
        end
    end
end
