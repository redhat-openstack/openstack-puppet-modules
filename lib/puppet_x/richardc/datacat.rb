module Puppet_X
module Richardc
end
end

# Our much simpler version of Puppet::Parser::TemplateWrapper
class Puppet_X::Richardc::Datacat_Binding
  def initialize(d)
    @data = d
  end

  def get_binding
    binding()
  end
end

