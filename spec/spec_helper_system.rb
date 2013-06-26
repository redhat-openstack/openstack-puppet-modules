require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'

include RSpecSystemPuppet::Helpers

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  c.include RSpecSystemPuppet::Helpers

  c.before :suite do
    puppet_install

    puppet_module_install(:source => proj_root, :module_name => 'datacat')
    puppet_module_install(:source => proj_root + '/spec/fixtures/modules/demo1', :module_name => 'demo1')
    puppet_module_install(:source => proj_root + '/spec/fixtures/modules/demo2', :module_name => 'demo2')
  end
end
