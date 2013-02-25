require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet_x', 'richardc', 'datacat.rb'))

Puppet::Type.type(:datacat_fragment).provide(:datacat_fragment) do
  mk_resource_methods

  def data
    debug "Publishing '#{@resource[:data].inspect}'"
    Puppet_X::Richardc::Datacat.set_data(@resource[:target], @resource[:data])
    @resource[:data]
  end
end
