Puppet::Type.type(:datacat_collector).provide(:datacat_collector) do
  mk_resource_methods

  def flush
    data = Puppet::Type::Datacat.get_data(@resource[:path])
    debug "Collected #{data.inspect}"

    vars = Puppet::Type::Datacat::Binding.new(data)

    debug "Applying template #{@resource[:template]}"
    template = ERB.new(@resource[:template_body] || '', 0, '-')
    template.filename = @resource[:template]
    content = template.result(vars.get_binding)

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

class Puppet::Type::Datacat
end

class Puppet::Type::Datacat::Binding
  def initialize(d)
    @data = d
  end

  def get_binding
    binding()
  end
end
