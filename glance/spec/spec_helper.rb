# Load libraries from openstacklib here to simulate how they live together in a real puppet run (for provider unit tests)
$LOAD_PATH.push(File.join(File.dirname(__FILE__), 'fixtures', 'modules', 'openstacklib', 'lib'))
require 'puppetlabs_spec_helper/module_spec_helper'
require 'shared_examples'
require 'webmock/rspec'

RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_configures, 'configures'
  c.alias_it_should_behave_like_to :it_raises, 'raises'
  c.before :each do
    @default_facts = { :os_service_default => '<SERVICE DEFAULT>' }
  end
end

at_exit { RSpec::Puppet::Coverage.report! }
