Puppet::Type.newtype(:swift_object_expirer_config) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from /etc/swift/object-expirer.conf'
    newvalues(/\S+\/\S+/)
  end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |value|
      value = value.to_s.strip
      value.capitalize! if value =~ /^(true|false)$/i
      value
    end

    def is_to_s( currentvalue )
      if resource.secret?
        return '[old secret redacted]'
      else
        return currentvalue
      end
    end

    def should_to_s( newvalue )
      if resource.secret?
        return '[new secret redacted]'
      else
        return newvalue
      end
    end
  end

  newparam(:secret, :boolean => true) do
    desc 'Whether to hide the value from Puppet logs. Defaults to `false`.'
    newvalues(:true, :false)
    defaultto false
  end

  # Require the package providing object-expirer to be present
  if Facter['osfamily'].value == 'Debian'
    autorequire(:package) do
      'swift-object-expirer'
    end
  elsif Facter['osfamily'].value == 'RedHat'
    autorequire(:package) do
      'openstack-swift-proxy'
    end
  end

end
