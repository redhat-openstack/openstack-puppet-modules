source ENV['GEM_SOURCE'] || "https://rubygems.org"

puppetversion = ENV.key?('PUPPET_GEM_VERSION') ? " #{ENV['PUPPET_GEM_VERSION']}" : ['>= 4.0']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '>= 0.3.2'
gem 'facter', '>= 1.7.0'
gem 'metadata-json-lint'
gem 'docker-api'
gem 'pry'
gem 'vagrant-wrapper'
gem 'coveralls', require: false

group :system_tests do
  gem 'beaker-rspec',         :require => false
  gem 'puppet-blacksmith',    :require => false
  gem 'rspec-puppet',         :require => false
  gem 'rspec-puppet-utils',   :require => false
  gem 'serverspec',           :require => false
end
