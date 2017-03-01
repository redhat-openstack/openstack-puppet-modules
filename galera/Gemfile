source 'https://rubygems.org'

group :development, :test do
  gem 'puppetlabs_spec_helper',  :require => false
  gem "rspec-puppet",            :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppet-lint',             :git => 'https://github.com/rodjek/puppet-lint.git'
  gem 'puppet-lint-param-docs',  '1.1.0'
  gem 'puppet-syntax'
  gem 'rake',                    :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
