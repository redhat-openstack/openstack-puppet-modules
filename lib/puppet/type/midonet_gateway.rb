require 'uri'
require 'facter'

Puppet::Type.newtype(:midonet_gateway) do
  @doc = %q{BGP Uplink Configuration

      Example:

        midonet_gateway {'hostname':
           midonet_api_url     => 'http://controller:8080',
           username            => 'admin',
           password            => 'admin',
           tenant_name         => 'admin',
           interface           => 'eth1',
           local_as            => '64512',
           bgp_port            => { 'port_address' => '198.51.100.2', 'net_prefix' => '198.51.100.0', 'net_length' => '30'},
           remote_peers        => [ { 'as' => '64513', 'ip' => '198.51.100.1' },
                                    { 'as' => '64513', 'ip' => '203.0.113.1' } ],
           advertise_net       => [ { 'net_prefix' => '192.0.2.0', 'net_length' => '24' } ]
}
  }

  ensurable

  autorequire(:package) do ['midolman'] end

  newparam(:hostname, :namevar => true) do
    desc 'Hostname of the host that will act as gateway in a MidoNet managed cloud'
    # Regex obtained from StackOverflow question:
    # http://stackoverflow.com/questions/1418423/the-hostname-regex
    validate do |value|
      unless value =~ /^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$/
        raise ArgumentError, "'%s' is not a valid hostname" % value
      end
    end
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
    defaultto 'admin'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid username" % value
      end
    end
  end

  newparam(:password) do
    desc 'Password of the admin user in keystone'
    defaultto 'admin'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid password" % value
      end
    end
  end

  newparam(:tenant_name) do
    desc 'Tenant name of the admin user'
    defaultto 'admin'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a tenant name" % value
      end
    end
  end

  newparam(:interface) do
    desc "Physical interface where the MidoNet Provider Router's port is binded to"
    defaultto 'eth0'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid interface" % value
      end
    end
  end

  newparam(:local_as) do
    desc "Local AS number"
    validate do |value|
      unless value =~ /\d+/
        raise ArgumentError, "'%s' is not a valid AS" % value
      end
    end
  end

  newparam(:remote_peers) do
    desc "#to be filled"
    defaultto []
    validate do |value|
      if value.class == Hash
        value = [value]
      end
      value.each do |rp|
        unless rp["as"] =~ /\d+/
          raise ArgumentError, "'%s' is not a valid AS name" % rp["as"]
        end
        unless rp["ip"] =~ /^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$/
          raise ArgumentError, "'%s' is not a valid IP address" % rp["ip"]
        end
      end
    end
  end

  newparam(:bgp_port) do
    desc "#to be filled"
    validate do |value|
      [:port_address, :net_prefix, :net_length].all? {|key| value.key? key}
      unless value["port_address"] =~  /^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$/
        raise ArgumentError, "'%s' is not a valid IP address" % value["port_address"]
      end
      unless value["net_prefix"] =~ /^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$/
        raise ArgumentError, "'%s' is not a valid IPv4 network address" % value["net_prefix"]
      end
      unless value["net_length"] =~ /\d{2}/
        raise ArgumentError, "'%s' is not a valid network prefix length" % value["net_length"]
      end
    end
  end

  newparam(:router) do
    desc "The MidoNet's internal Provider router that acts as the gateway router of the cloud"
    defaultto 'MidoNet Provider Router'
    validate do |value|
      unless value =~ /\w+$/
        raise ArgumentError, "'%s' is not a valid router name" % value
      end
    end
  end

  newparam(:advertise_net) do
    desc 'Floating IP network to be avertised to the BGP peers'
    defaultto []
    validate do |value|
      if value.class == Hash
        value = [value]
      end
      value.each do |an|
        unless an["net_prefix"] =~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
          raise ArgumentError, "'%s' is not a valid network prefix" % an["net_prefix"]
        end
        unless an["net_length"] =~ /\d{2}/
          raise ArgumentError, "'%s' is not a valid network prefix length" % an["net_length"]
        end
      end
    end
  end

end

