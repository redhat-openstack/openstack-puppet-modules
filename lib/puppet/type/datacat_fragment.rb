Puppet::Type.newtype(:datacat_fragment) do
  newparam(:name, :namevar => true) do
  end

  newparam(:target) do
  end

  newproperty(:data) do
  end
end
