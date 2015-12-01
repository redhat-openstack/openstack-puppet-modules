source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 2.7.0','< 4.0']
gem 'puppet', puppetversion
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'
gem 'rake'
# librarian 2 does not support ruby 1.8.7
gem 'librarian-puppet', '< 2.0'
gem 'highline', '< 1.7' # 1.7 is not compatible with ruby 1.8.7
gem 'rspec-system-puppet',     :require => false
gem 'serverspec',              :require => false
gem 'rspec-system-serverspec', :require => false
# coverage reports will be in release 2.0
gem 'rspec-puppet', '> 2.0'
gem 'rspec', '~> 2.13'

# blacksmith > 3.0 does not support ruby 1.8.7
group :development do
  gem 'puppet-blacksmith',  '~> 3.0'
  gem 'metadata-json-lint',      :require => false
  gem 'beaker'
  gem 'beaker-rspec', :require => false
end