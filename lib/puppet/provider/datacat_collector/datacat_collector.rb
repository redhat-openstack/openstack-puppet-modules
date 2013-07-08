require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'richardc', 'datacat.rb'))

Puppet::Type.type(:datacat_collector).provide(:datacat_collector) do
  mk_resource_methods

  def exists?
    # Find the datacat_fragments that point at this collector
    our_names = [ resource[:path], resource[:collects] ].flatten.compact

    fragments = resource.catalog.resources.find_all do |r|
      r.is_a?(Puppet::Type.type(:datacat_fragment)) && ((our_names & [ r[:target] ].flatten).size > 0)
    end

    # order fragments on their :order property
    fragments = fragments.sort { |a,b| a[:order] <=> b[:order] }

    # deep merge their data chunks
    deep_merge = Puppet_X::Richardc::Datacat.deep_merge
    data = {}
    fragments.each do |fragment|
      data.merge!(fragment[:data], &deep_merge)
    end

    debug "Collected #{data.inspect}"

    vars = Puppet_X::Richardc::Datacat_Binding.new(data, resource[:template])

    debug "Applying template #{@resource[:template]}"
    template = ERB.new(@resource[:template_body] || '', 0, '-')
    template.filename = @resource[:template]
    content = template.result(vars.get_binding)

    # Find the resource to modify
    target_resource = @resource[:target_resource]
    target_field    = @resource[:target_field].to_sym

    # Resolve it to the real resource
    if target_resource.class == Puppet::Resource
      target_resource.catalog = resource.catalog
      target_resource = target_resource.resolve
    end

    debug "Found resource #{target_resource.inspect} class #{target_resource.class} field #{target_field.inspect}"
    target_resource[target_field] = content
    debug "Have set resource #{target_resource.inspect}"

    # and claim there's nothing to change about *this* resource
    true
  end
end
