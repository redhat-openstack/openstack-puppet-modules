Puppet::Type.newtype(:datacat_collector) do
  desc 'This type is not used directly, it is wrapped by the datacat define'
  ensurable

  newparam(:path, :namevar => true) do
    desc 'The path of the file we\'re collecting for.'
  end

  newparam(:target_resource) do
    desc 'The resource to set data to'
  end

  newparam(:target_field) do
    desc 'The field of the resource to put the results in'
  end

  newparam(:template) do
    desc 'Path to the template to render.  Used in error reporting.'
  end

  newparam(:template_body) do
    desc 'The slurped body of the template to render.'
  end
end
