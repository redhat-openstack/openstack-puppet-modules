source 'https://rubygems.org'

puppetversion = ENV['PUPPET_VERSION']
rspecversion = ENV.key?('RSPEC_VERSION') ? "= #{ENV['RSPEC_VERSION']}" : ['>= 2.9 ', '< 3.0.0']
gem 'puppet', puppetversion, :require => false
gem 'puppet-lint'
gem 'rspec-puppet'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-syntax'
