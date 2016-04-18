Puppet::Type.newtype(:qdr_user) do
  desc "Type for managing qdr users such as with sasl provider, etc."

  ensurable

  newparam(:name, :namevar => true) do
    desc "The name of user"
    newvalues(/^\S+$/)
  end

  newparam(:file) do
    desc "The location of the sasl password file"
    newvalues(/^\S+$/)
  end

  newparam(:password) do
    desc "The user password to be set on creation"
  end

  validate do
    if self[:ensure] == :present and ! self[:password]
      raise Puppet::ArgumentError => "Must set password when creating user" 
    end
  end

end
