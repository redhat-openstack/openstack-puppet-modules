require 'puppet/property/boolean'
require 'puppet/type'

Puppet::Type.newtype(:rhn_register) do
  @doc = ""

  ensurable do

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    def insync?(is)

      @should.each do |should|
        case should
        when :present
          return true if is == :present
        when :absent
          return true if is == :absent
        end
      end

      return false
    end

    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc "The Server name."

  end

  newparam(:profile_name) do
    desc "The name the system should use in RHN or Satellite"

  end

  newparam(:username) do
    desc "The username to use when registering the system"
    
  end

  newparam(:password) do
    desc "The password to use when registering the system"

  end

  newparam(:activationkeys) do
    desc "The activation key to use when registering the system (cannot be used with username and password)"

  end

  newparam(:hardware, :parent => Puppet::Property::Boolean) do
    desc "Whether or not the hardware information should be probed"

    defaultto true

  end

  newparam(:packages, :parent => Puppet::Property::Boolean) do
    desc "Whether or not packages information should be probed"

    defaultto true

  end

  newparam(:virtinfo, :parent => Puppet::Property::Boolean) do
    desc "Whether or not virtualiztion information should be uploaded"

    defaultto true
  end

  newparam(:rhnsd, :parent => Puppet::Property::Boolean) do
    desc "Whether or not rhnsd should be started after registering"

    defaultto true
  end

  newparam(:force, :parent => Puppet::Property::Boolean) do
    desc "Should the registration be forced. Use this option with caution,
          setting it true will cause the rhnreg_ks command to be run every time
          runs."

    defaultto false
  end

  newparam(:proxy) do
    desc "If needed, specify the HTTP Proxy"

  end

  newparam(:proxy_user) do
    desc "Specify a username to use with an authenticated http proxy"

  end

  newparam(:proxy_password) do
    desc "Specify a password to use with an authenticated http proxy"

  end

  newparam(:ssl_ca_cert) do
    desc "Specify a file to use as the ssl CA cert"
    #defaultto :"/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT"

  end

  newparam(:server_url) do
    desc "Specify a url to use as a server"

  end

end
