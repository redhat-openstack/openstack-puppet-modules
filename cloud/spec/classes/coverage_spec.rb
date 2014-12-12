require 'spec_helper'

if ENV['COV']
  at_exit { RSpec::Puppet::Coverage.report! }
end
