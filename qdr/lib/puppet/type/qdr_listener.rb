Puppet::Type.newtype(:qdr_listener) do
  desc "Type for managing qdrouterd listener instances"

  ensurable 
  
  # TODO(ansmith) - dynamic autorequire for qdrouterd service
  #  autorequire(:service) { 'qdrouterd' }
  newparam(:name, :namevar => true) do
    desc "The unique name for the listener"
    newvalues(/^\S+$/)
  end

  newproperty(:addr) do
    desc "The listening host's IP address, IPv4 or IPv6"
  end

  newproperty(:port) do
    desc "The listening port number on the host"
  end

  newproperty(:role) do
    desc "The role for connections established by the listener"
    defaultto :normal
    newvalues(:normal, :inter_router, :on_demand)
  end

  newproperty(:sasl_mechanisms) do
    desc "List of accepted SASL authentication mechansisms"
    defaultto "ANONYMOUS,DIGEST-MD5,EXTERNAL,PLAIN"
  end

  newproperty(:auth_peer) do
    defaultto :false
    newvalues(:true, :false)

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end
    
  end

  newproperty(:require_encryption) do
    desc "Require the connection to the peer to be encryped"
    defaultto :false
    newvalues(:true, :false)

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end
    
  end
  
  newproperty(:require_ssl) do
    desc "Require the use of SSL or TLS on the connection"
    defaultto :false
    newvalues(:true, :false)

    def should_to_s(value)
      value.inspect
    end

    def is_to_s(value)
      value.inspect
    end
    
  end

  newproperty(:max_frame_size) do
    desc "The largest contiguous set of uninterrupted data that can be sent"
    defaultto ('65536')

    validate do |value|
      unless value =~ /\d{1,5}/ &&
             value.to_i <= 65536
        fail("Invalid max frame size #{value}")
      end
    end
  end

  
end
