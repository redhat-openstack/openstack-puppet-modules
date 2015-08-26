require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
Blacksmith::RakeTask.new do |t|
  t.tag_pattern = "%s" # Use a custom pattern with git tag. %s is replaced with the version number.
end
