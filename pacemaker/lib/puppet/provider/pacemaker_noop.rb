# this is the abstract provider to create "noop" providers for pacemaker types
# if a "noop" provider is used for a resource it will do nothing when applied
# neither the retrieving nor the modification phase
class Puppet::Provider::PacemakerNoop < Puppet::Provider
  attr_accessor :property_hash
  attr_accessor :resource

  # stub "exists?" method that returns "true" and logs its calls
  # @return [true]
  def exists?
    debug 'Call: exists?'
    make_property_methods
    out = true
    debug "Return: #{out}"
    out
  end

  # stub "creat" method method cleans the property hash
  # should never be actually called because exists? always returns true
  def create
    debug 'Call: create'
    self.property_hash = {}
  end

  # stub "destroy" method cleans the property hash
  def destroy
    debug 'Call: destroy'
    self.property_hash = {}
  end

  # stub "flush" method does nothing
  def flush
    debug 'Call: flush'
  end

  # this method creates getters and setters for each
  # of the resource properties
  # works directly with resource parameter values instead of property_hash
  def make_property_methods
    properties = resource.properties.map(&:name)
    properties.each do |property|
      next if property == :ensure
      self.class.send :define_method, property do
        debug "Call: #{property}"
        out = resource[property]
        debug "Return: #{out.inspect}"
        out
      end
      self.class.send :define_method, "#{property}=" do |value|
        debug "Call: #{property}=#{value.inspect}"
        resource[property] = value
      end
    end
  end
end
