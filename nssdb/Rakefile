require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rake/clean'

CLEAN.include('spec/fixtures/', 'spec/reports')

task :spec => [:spec_prep]

desc "Run all tasks (spec)"
task :all => [ :spec ]
