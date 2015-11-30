require 'puppet'
require 'rspec'
require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet/coverage'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.include PuppetlabsSpec::Files
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'

  c.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    if ENV['STRICT_VARIABLES'] == 'yes'
      Puppet.settings[:strict_variables]=true
    end
  end
  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
  # we don't want to run tests from submodules in fixtures/cron/..
  c.pattern = "spec/*/*_spec.rb"
  c.default_facts = {
    :kernel          => 'Linux',
    :concat_basedir  => '/var/lib/puppet/concat',
  }
end

Puppet::Util::Log.level = :warning
Puppet::Util::Log.newdestination(:console)

at_exit { RSpec::Puppet::Coverage.report! }
