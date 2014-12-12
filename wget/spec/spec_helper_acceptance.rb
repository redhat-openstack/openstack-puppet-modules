require 'puppet'
require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

RSpec.configure do |c|

  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end

  c.before :suite do
    hosts.each do |host|
      unless (ENV['RS_PROVISION'] == 'no' || ENV['BEAKER_provision'] == 'no')
        begin
          on host, 'puppet --version'
        rescue
          if host.is_pe?
            install_pe
          else
            install_puppet
          end
        end
      end

      # Install module and dependencies
      puppet_module_install(:source => proj_root, :module_name => 'wget')
    end
  end

end
