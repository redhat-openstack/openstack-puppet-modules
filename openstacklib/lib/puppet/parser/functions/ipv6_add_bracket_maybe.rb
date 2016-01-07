require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:ipv6_add_bracket_maybe, 
              :type => :rvalue, 
              :arity => 1,
              :doc => <<-EOD
    Add brackets if the argument is an IPv6 address. 
    Returns the argument otherwise.
    EOD
  ) do |args|
    ip = args[0]
    begin
      if IPAddr.new(ip).ipv6?
        ip = "[#{ip}]" unless ip.match(/\[.+\]/)
      end
    rescue ArgumentError => e
      # ignore it
    end
    return ip
  end
end
