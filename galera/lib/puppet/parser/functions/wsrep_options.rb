module Puppet::Parser::Functions
  newfunction(:wsrep_options, :type => :rvalue) do |args|
    opts = args[0]
    opts.delete_if {|key, val| val.equal? :undef}
    opts.sort.map do |k,v|
      String(k) + "=" + String(v)
    end
  end
end
