source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, fake_version = nil)
  if place =~ /^(git[:@][^#]*)#(.*)/
    [fake_version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, { :require => false }]
  end
end

group :test do
  gem 'rake',                                                       :require => false
  gem 'rspec-puppet',                                               :require => false
  gem 'puppet-lint',                                                :require => false
  gem 'metadata-json-lint',                                         :require => false
  gem 'rspec-puppet-facts',                                         :require => false
  gem 'rspec',                                                      :require => false
  gem 'rspec-puppet-utils',                                         :require => false
  gem 'puppet-lint-absolute_classname-check', '~> 0.2.4',           :require => false
  gem 'puppet-lint-leading_zero-check',                             :require => false
  gem 'puppet-lint-trailing_comma-check',                           :require => false
  gem 'puppet-lint-version_comparison-check',                       :require => false
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check',  :require => false
  gem 'puppet-lint-unquoted_string-check',                          :require => false
  gem 'puppet-lint-variable_contains_upcase',                       :require => false
  gem 'rubocop',                                                    :require => false
  gem 'unicode-display_width',                                      :require => false
  gem 'puppetlabs_spec_helper',                                     :require => false
end

group :development do
  gem 'pry'
end

group :system_tests do
  #TODO: to be removed when
  #https://tickets.puppetlabs.com/browse/BKR-851 is resolved.
  gem 'specinfra', '= 2.59.0'

  if beaker_version = ENV['BEAKER_VERSION']
    gem 'beaker', *location_for(beaker_version)
  else
    gem 'beaker',                        :require => false
  end
  if beaker_rspec_version = ENV['BEAKER_RSPEC_VERSION']
    gem 'beaker-rspec', *location_for(beaker_rspec_version)
  else
    gem 'beaker-rspec',  :require => false
  end
  gem 'beaker-puppet_install_helper',  :require => false
end



if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion.to_s, :require => false, :groups => [:test]
else
  gem 'facter', :require => false, :groups => [:test]
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false, :groups => [:test]
else
  gem 'puppet', :require => false, :groups => [:test]
end

# vim:ft=ruby
