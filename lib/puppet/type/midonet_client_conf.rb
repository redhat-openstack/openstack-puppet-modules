Puppet::Type.newtype(:midonet_client_conf) do

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Section/setting name to manage from .midonetrc'
    newvalues(/\S+\/\S+/)
  end

  autorequire(:package) do ['python-midonetclient'] end

  newproperty(:value) do
    desc 'The value of the setting to be defined.'
    munge do |value|
      value = value.to_s.strip
      value.capitalize! if value =~ /^(true|false)$/i
      value
    end

    def is_to_s( currentvalue )
      return currentvalue
    end

    def should_to_s( newvalue )
      return newvalue
    end
  end

end
