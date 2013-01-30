Puppet::Type.type(:datacat_collector).provide(:datacat_collector) do
    mk_resource_methods

    def flush
        debug "flushing"

        data = Puppet::Type::Datacat.get_data(@resource[:path])
        debug "Collected #{data.inspect}"

        # XXX TODO do the template eval
        content = "#{data.to_yaml}\n"

        # In the containing datacat define we created a sibling file
        # resource which will do much of the heavy lifting, and left a
        # reference to it in our before metaparameter.  Now it's time to
        # find that resource and update its content to the results of
        # our template evaluation.
        target_file = @resource[:before].find do |r|
            r.type == 'File' and r.title == @resource[:path]
        end
        # @resource[:before] contrains resource references, dereference it
        target_file = target_file.resolve

        debug "Found resource #{target_file.inspect} class #{target_file.class}"
        target_file[:content] = content
    end
end
