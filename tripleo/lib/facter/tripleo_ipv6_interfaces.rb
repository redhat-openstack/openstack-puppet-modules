
require 'ipaddr'


ipv6_regex = /inet6 ((?>[0-9,a-f,A-F]*\:{1,2})+[0-9,a-f,A-F]{0,4}\/[0-9]{1,3})/


def get_ipv6_output(interface)
  cmd = ['/sbin/ip', '/usr/sbin/ip'].select {
    |path| File.executable?(path)
  }.first
  Facter::Core::Execution.execute(
    "#{cmd} -6 addr show dev #{interface}"
  )
end


Facter.add("tripleo_ipv6_interfaces") do
  setcode do
    value = {}
    Facter::Util::IP.get_interfaces.each do |interface|
      interface = Facter::Util::IP.alphafy(interface)
      # skip interfaces which don't have ipv6 address
      begin
        ip_output = get_ipv6_output(interface)
        if ! ipv6_regex.match ip_output
          raise Facter::Core::Execution::ExecutionFailure
        end
      rescue Facter::Core::Execution::ExecutionFailure
        next
      end
      value[interface] = []
      ip_output.each_line do |line|
        if match = ipv6_regex.match(line)
          cidr = IPAddr.new match[1]
          cidr_arr = cidr.inspect().split('/', 2)
          value[interface].push({
              'ipaddress' => cidr_arr[0].split('IPv6:', 2)[1],
              'netmask' => cidr_arr[1].split('>', 2)[0]
          })
        end
      end
    end
    value
  end
end
