require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'richardc', 'datacat.rb'))

Puppet::Type.type(:datacat_collector).provide(:datacat_collector) do
  mk_resource_methods

  def flush
    # Find the datacat_fragments that point at this collector
    fragments = resource.catalog.resources.find_all do |r|
      r.is_a?(Puppet::Type.type(:datacat_fragment)) && r[:target] == resource[:path]
    end

    # deep merge their data chunks
    deep_merge = Proc.new do |key,oldval,newval|
      newval.is_a?(Hash) && oldval.is_a?(Hash) ?
        oldval.merge(newval, &deep_merge) :
        newval.is_a?(Array) && oldval.is_a?(Array) ?
          oldval + newval :
          newval
    end

    data = {}
    fragments.each do |fragment|
      data.merge!(fragment[:data], &deep_merge)
    end

    debug "Collected #{data.inspect}"

    vars = Puppet_X::Richardc::Datacat_Binding.new(data)

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
    # @resource[:before] contains resource references, dereference it
    target_file = target_file.resolve

    debug "Found resource #{target_file.inspect} class #{target_file.class}"
    target_file[:content] = content
  end
end
