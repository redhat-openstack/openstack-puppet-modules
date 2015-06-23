require 'beaker-rspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper

UNSUPPORTED_PLATFORMS = ['Darwin', 'Suse','windows','AIX','Solaris']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'haproxy')
    hosts.each do |host|
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      if fact('osfamily') == 'RedHat'
        on host, puppet('module','install','stahnma/epel'), { :acceptable_exit_codes => [0,1] }
      end
      if fact('operatingsystem') == 'Debian'
        on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
        apply_manifest(%{
          include apt
          include apt::backports
        })
      end
      if ! UNSUPPORTED_PLATFORMS.include?(fact('osfamily'))
        pp = <<-EOS
          $netcat = $::osfamily ? {
            'RedHat' => $::operatingsystemmajrelease ? {
              '7'     => 'nmap-ncat',
              default => 'nc',
            },
            'Debian' => 'netcat-openbsd',
          }
          package { $netcat: ensure => present, }
          package { 'screen': ensure => present, }
          if $::osfamily == 'RedHat' {
            class { 'epel': }
            service { 'iptables': ensure => stopped, }
            exec { 'setenforce Permissive':
              path   => ['/bin','/usr/bin','/sbin','/usr/sbin'],
              onlyif => 'getenforce | grep Enforcing',
            }
            if $::operatingsystemmajrelease == '7' {
              # For `netstat` for serverspec
              package { 'net-tools': ensure => present, }
            }
          }
        EOS
        apply_manifest(pp, :catch_failures => true)

        ['5556','5557'].each do |port|
          shell(%{echo 'while :; do echo "HTTP/1.1 200 OK\r\n\r\nResponse on #{port}" | nc -l #{port} ; done' > /root/script-#{port}.sh})
          shell(%{/usr/bin/screen -dmS script-#{port} sh /root/script-#{port}.sh})
          sleep 1
          shell(%{netstat -tnl|grep ':#{port}'})
        end
      end
    end
  end
end
