source :rubygems

if ENV.key?('PUPPET_VERSION')
  puppetversion = "= #{ENV['PUPPET_VERSION']}"
 else
  puppetversion = ['>= 3.4']
end

gem 'rake', '~> 10.1.1'
gem 'puppet-lint'
gem 'puppet-syntax'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper'
gem 'puppet', puppetversion
