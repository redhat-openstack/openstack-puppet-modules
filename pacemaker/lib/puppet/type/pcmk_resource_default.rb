require 'puppet/parameter/boolean'

Puppet::Type.newtype(:pcmk_resource_default) do
  @doc = "A default value for pacemaker resource options"

  ensurable

  newparam(:name) do
    desc "A unique name of the option"
  end

  newparam(:value) do
    desc "A default value for the option"
  end

end
