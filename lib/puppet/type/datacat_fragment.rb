Puppet::Type.newtype(:datacat_fragment) do
  desc 'A fragment of data for a datacat resource.'

  newparam(:name, :namevar => true) do
    desc 'The name of this fragment.'
  end

  newparam(:target) do
    desc 'The title of the datacat resource that the data should be sent to.'
  end

  newproperty(:data) do
    desc 'A hash of data to be merged for this resource.'
  end
end
