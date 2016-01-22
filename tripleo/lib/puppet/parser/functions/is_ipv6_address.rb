#
# is_ipv6_address.rb
#

require 'ipaddr'

module Puppet::Parser::Functions
  newfunction(:is_ipv6_address, :type => :rvalue,
              :doc => ("Returns true if the string passed to this function" +
                       "is a valid IPv6 address.")) do |arguments|

    if (arguments.size != 1) then
      raise(Puppet::ParseError, "is_ipv6_address(): Wrong number of arguments "+
        "given #{arguments.size} for 1")
    end

    begin
      ip = IPAddr.new(arguments[0])
    rescue ArgumentError
      return false
    end

    return ip.ipv6?
  end
end
