require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    hosts.each do |host|
      copy_module_to(host, :source => proj_root, :module_name => 'midonet')
      scp_to(host, proj_root + '/data/hiera.yaml', "#{default['puppetpath']}/hiera.yaml")
      on host, 'mkdir -p /var/lib/hiera'
      scp_to(host, proj_root + '/data/common.yaml', "/var/lib/hiera")
      scp_to(host, proj_root + '/data/osfamily', "/var/lib/hiera")

      on host, puppet('module install ripienaar-module_data'), {:acceptable_exit_codes => [0,1] }
      on host, puppet('module install puppetlabs-stdlib --version 4.5.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module install deric-zookeeper'), {:acceptable_exit_codes => [0,1] }
      on host, puppet('module install midonet-cassandra'), {:acceptable_exit_codes => [0,1] }
      on host, puppet('module install puppetlabs-inifile'), {:acceptable_exit_codes => [0,1] }
      on host, puppet('module install puppetlabs-apt'), {:acceptable_exit_codes => [0,1] }
      on host, puppet('module install puppetlabs-java'), {:acceptable_exit_codes => [0,1] }
      on host, puppet('module install puppetlabs-tomcat'), {:acceptable_exit_codes => [0,1] }
    end
  end
end
