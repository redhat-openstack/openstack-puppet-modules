source 'https://rubygems.org'

gem 'puppet'
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
gem 'rake'
# librarian 2 does not support ruby 1.8.7
gem 'librarian-puppet', '< 2.0'
gem 'rspec-system-puppet',     :require => false
gem 'serverspec',              :require => false
gem 'rspec-system-serverspec', :require => false
gem 'rspec-puppet'

# blacksmith > 3.0 does not support ruby 1.8.7
group :development do
  gem 'puppet-blacksmith',  '~> 3.0'
end