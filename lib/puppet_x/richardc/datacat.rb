module Puppet_X
module Richardc
end
end

# Our much simpler version of Puppet::Parser::TemplateWrapper
class Puppet_X::Richardc::Datacat_Binding
  def initialize(d, template)
    @data = d
    @__file__ = template
  end

  def file
    @__file__
  end

  # Find which line in the template (if any) we were called from.
  # @return [String] the line number
  # @api private
  def script_line
    identifier = Regexp.escape(@__file__ || "(erb)")
    (caller.find { |l| l =~ /#{identifier}:/ }||"")[/:(\d+):/,1]
  end
  private :script_line

  def method_missing(name, *args)
    line_number = script_line
    raise "Could not find value for '#{name}' #{@__file__}:#{line_number}"
  end

  def get_binding
    binding()
  end
end

