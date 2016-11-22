# Managed by modulesync
# Configs https://github.com/sbadia/modulesync_configs/
#
require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'

  # custom facts for rspec-puppet-facts
  add_custom_fact :puppetversion, Puppet.version
end

at_exit { RSpec::Puppet::Coverage.report! }
