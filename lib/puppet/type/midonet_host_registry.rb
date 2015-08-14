require 'uri'
require 'facter'

Puppet::Type.newtype(:midonet_host_registry) do
  @doc = %q{Register a Host to a MidoNet tunnel zone
    through the MidoNet API

      Example:

        midonet_host_registry {'hostname':
          $midonet_api_url     => 'http://controller:8080',
          $username            => 'admin',
          $password            => 'admin',
          $underlay_ip_address => '123.23.43.2'
        }
  }
  ensurable

  newparam(:hostname, :namevar => true) do
    desc 'Hostname of the host that wants to register in MidoNet cloud'
    # Regex obtained from StackOverflow question:
    # http://stackoverflow.com/questions/1418423/the-hostname-regex
    validate do |value|
      unless value =~ /^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$/
        raise ArgumentError, "'%s' is not a valid hostname" % value
      end
    end
  end

  newparam(:tunnelzone_name) do
    desc 'Name of the tunnelzone. If it does not exist, it creates one'
    defaultto :'tzone0'
    validate do |value|
      unless value =~ /\w+/
        raise ArgumentError, "'%s' is not a valid tunnelzone name" % value
      end
    end
  end

  newparam(:tunnelzone_type) do
    desc 'Network technology to use when creating the tunnel'
    defaultto 'gre'
    newvalues('gre', 'vxlan')
  end

  newparam(:midonet_api_url) do
    desc 'MidoNet API endpoint to connect to'
    validate do |value|
      unless value =~ /\A#{URI::regexp(['http', 'https'])}\z/
        raise ArgumentError, "'%s' is not a valid URI" % value
      end
    end
  end

  newparam(:username) do
    desc 'Username of the admin user in keystone'
    validate do |value|
      unless value =~ /\w+/
        raise ArgumentError, "'%s' is not a valid username" % value
      end
    end
  end

  newparam(:password) do
    desc 'Password of the admin user in keystone'
    validate do |value|
      unless value =~ /\w+/
        raise ArgumentError, "'%s' is not a valid password" % value
      end
    end
  end

  newparam(:tenant_name) do
    desc 'Tenant name of the admin user'
    defaultto :'admin'
    validate do |value|
      unless value =~ /\w+/
        raise ArgumentError, "'%s' is not a tenant name" % value
      end
    end
  end

  newparam(:underlay_ip_address) do
    desc "IP address that will be used to as the underlay layer to
          create the tunnels. It will take the fact $ipaddress by
          default"
    defaultto Facter['ipaddress'].value
    validate do |value|
      unless value =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
        raise ArgumentError, "'%s' is not a valid IPv4 address" % value
      end
    end
  end

end
