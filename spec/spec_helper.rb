require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'coveralls'
Coveralls.wear!
at_exit { RSpec::Puppet::Coverage.report! }
