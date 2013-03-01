module Puppet_X
module Richardc
end
end

class Puppet_X::Richardc::Datacat
  @@data = {}

  def self.set_data(path, data)
    @@data[path] ||= {}

    deep_merge = Proc.new do |key,oldval,newval|
      newval.is_a?(Hash) && oldval.is_a?(Hash) ?
        oldval.merge(newval, &deep_merge) :
        newval.is_a?(Array) && oldval.is_a?(Array) ?
          oldval + newval :
          newval
    end
    @@data[path].merge!(data, &deep_merge)
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

