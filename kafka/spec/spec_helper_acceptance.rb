require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  foss_opts = { :default_action => 'gem_install' }

  install_puppet( foss_opts )
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation

  c.before :suite do
    hosts.each do |host|
      c.host = host

      path = (File.expand_path(File.dirname(__FILE__)+'/../')).split('/')
      name = path[path.length-1].split('-')[1]

      copy_module_to(host, :source => proj_root, :module_name => name)

      on host, puppet('module install puppetlabs-stdlib --version 4.5.1'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install puppetlabs-java --version 1.3.0'), { :acceptable_exit_codes => [0] }
      on host, puppet('module install deric-zookeeper --version 0.3.5'), { :acceptable_exit_codes => [0] }

    end
  end
end
