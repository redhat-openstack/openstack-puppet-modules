source "https://rubygems.org"

group :rake do
  # tests need puppet >= 3.4.0
  gem 'puppet', ENV['PUPPET_VERSION'] || '>=3.4.0', :require => false
  gem 'rspec-puppet', '>=1.0.0', :require => false
  gem 'rake',         '>=0.9.2.2', :require => false
  gem 'puppet-lint',  '>=1.0.0', :require => false
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-blacksmith', '>=1.0.5', :require => false
  gem 'beaker', '>=1.17.0', :require => false
  gem 'beaker-rspec', '>=2.1.0', :require => false
end
