require_relative '../../pacemaker/options'
require_relative '../../pacemaker/type'

Puppet::Type.newtype(:pacemaker_online) do
  desc 'Wait for pacemaker to become online'

  newparam(:name) do
    isnamevar
  end

  newproperty(:status) do
    desc 'Should we wait for online or offline status'
    defaultto :online
    newvalues :online, :offline
  end

  autorequire(:service) do
    %w(corosync pacemaker)
  end
end
