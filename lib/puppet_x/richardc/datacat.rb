module Puppet_X
module Richardc
end
end

class Puppet_X::Richardc::Datacat
  @@data = {}

  def self.set_data(path, data)
    @@data[path] ||= {}
    @@data[path].merge!(data)
  end

  def self.get_data(path)
    @@data[path]
  end
end

class Puppet_X::Richardc::Datacat::Binding
  def initialize(d)
    @data = d
  end

  def get_binding
    binding()
  end
end

