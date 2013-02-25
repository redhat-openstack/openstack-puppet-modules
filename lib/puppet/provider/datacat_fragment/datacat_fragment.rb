Puppet::Type.type(:datacat_fragment).provide(:datacat_fragment) do
  mk_resource_methods

  def data
    debug "Publishing '#{@resource[:data].inspect}'"
    Puppet::Type::Datacat.set_data(@resource[:target], @resource[:data])
    @resource[:data]
  end
end
