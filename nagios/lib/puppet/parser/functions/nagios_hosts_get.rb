require 'yaml'

module Puppet::Parser::Functions
  newfunction(:nagios_hosts_get, :type => :rvalue, :doc => "") do
    hosts_dir='/var/lib/puppet/server_data/nagios/hosts'

    nagios_hosts = {}
    Dir["#{hosts_dir}/*"].each do |host|
      File.open(host) do |f|
        payload = YAML.load(f)
        hostname = File.basename(host)
        nagios_hosts.merge!({ hostname => payload }) if payload
      end
    end
    nagios_hosts
  end
end
