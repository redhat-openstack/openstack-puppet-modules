source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'puppet-lint', '>= 0.3.2'
gem 'facter', '>= 1.7.0'
gem 'test-kitchen', :git => 'git://github.com/jdevesa/test-kitchen', :branch => 'remove_ssh_retry_options'
gem 'kitchen-puppet'
gem 'librarian-puppet', '>= 2.0.1'
gem 'kitchen-docker', :git => 'git://github.com/jdevesa/kitchen-docker.git', :branch => 'wait_for_ssh'
gem 'kitchen-vagrant'
