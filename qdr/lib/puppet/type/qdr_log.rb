Puppet::Type.newtype(:qdr_log) do
  desc "Type for managing qdrouterd module log instances"

#  ensurable

  # TODO(ansmith) - dynamic autorequired for qdrouterd service
  # autorequire(:service) { "qdrouterd' }

  newparam(:name, :namevar => true) do
    desc "The unique name for the log module"
  end

  newproperty(:module) do
    desc "The qdrouterd log module source"
  end

#  newproperty(:role) do
#    desc "The role for connections established by the listener"
#    defaultto :normal
#    newvalues(:normal, :inter_router, :on_demand)
#  end

end
