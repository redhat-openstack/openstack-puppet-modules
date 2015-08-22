source ENV['GEM_SOURCE'] || "https://rubygems.org"

gem 'puppet'
gem 'puppet-blacksmith'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '>= 0.3.2'
gem 'facter', '>= 1.7.0'
gem 'metadata-json-lint'
gem 'pry'
gem 'vagrant-wrapper'
gem 'travis'
gem 'coveralls'

group :system_tests do
  gem 'beaker-rspec',         :require => false
  gem 'rspec-puppet',         :require => false
  gem 'rspec-puppet-utils',   :require => false
  gem 'serverspec',           :require => false
end
