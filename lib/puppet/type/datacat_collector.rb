Puppet::Type.newtype(:datacat_collector) do
  newparam(:path, :namevar => true) do
  end

  newproperty(:template) do
  end

  newparam(:template_body) do
  end
end
