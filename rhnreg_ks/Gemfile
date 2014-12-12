source :rubygems

gem 'puppet', '>= 2.6.0'
gem 'facter', '>= 1.6.1'

group :test, :development do
  gem 'rspec', '>= 2.13.0'
  gem 'mocha', '>= 0.13.2'
  gem 'puppetlabs_spec_helper', '>= 0.4.1' 
  gem 'rspec-puppet', '>= 0.1.5'
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
