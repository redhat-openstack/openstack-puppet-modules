require 'puppet'
require 'spec_helper'
require 'puppet/provider/gnocchi'


klass = Puppet::Provider::Gnocchi

describe Puppet::Provider::Gnocchi do

  after :each do
    klass.reset
  end

end
