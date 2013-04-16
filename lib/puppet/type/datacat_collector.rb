Puppet::Type.newtype(:datacat_collector) do
  desc 'This type is not used directly, it is wrapped by the datacat define'

  newparam(:path, :namevar => true) do
    desc 'The path of the file we\'re collecting for.'
  end

  newproperty(:template) do
    desc 'Path to the template to render.  Used in error reporting.'
  end

  newparam(:template_body) do
    desc 'The slurped body of the template to render.'
  end
end
