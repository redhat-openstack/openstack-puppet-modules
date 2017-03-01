source 'https://rubygems.org'

group :development, :unit_test do
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
# Highline 1.7 drops support for ruby 1.8. We must pin highline to < 1.7 until we drop 1.8 too.
  gem 'highline', '< 1.7.0',     :require => false
end

group :system_tests do
  gem 'serverspec',              :require => false
  gem 'rspec-system',            :require => false
  gem 'rspec-system-puppet',     :require => false
  gem 'rspec-system-serverspec', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# rspec must be v2 for ruby 1.8.7
if RUBY_VERSION >= '1.8.7' and RUBY_VERSION < '1.9'
  gem 'rspec', '~> 2.0'
end

# vim:ft=ruby
