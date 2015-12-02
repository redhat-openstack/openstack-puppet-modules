require 'beaker-rspec'

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host.is_pe?
      install_pe
    else
      install_puppet
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

UNSUPPORTED_PLATFORMS = ['windows']

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'uchiwa')
    hosts.each do |host|
      if fact('osfamily') == 'Debian'
        # RubyGems missing on some Vagrant boxes
        # Otherwise you'lll get a load of 'Provider gem is not functional on this host'
        shell('apt-get install rubygems -y')
        # TODO: puppetlabs-rabbitmq 4.1 doesn't support rabbitmq 3.4.0.
        #       Remove the following two lines after a new puppetlabs-rabbitmq release
        #       that contains PR #250
        shell('apt-get install erlang-nox -y')
        shell('wget http://www.rabbitmq.com/releases/rabbitmq-server/v3.3.5/rabbitmq-server_3.3.5-1_all.deb && sudo dpkg -i rabbitmq-server_3.3.5-1_all.deb')
      end
      if fact('osfamily') == 'RedHat'
        # RedHat needs EPEL for RabbitMQ and Redis
        shell('wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && sudo rpm -Uvh epel-release-6*.rpm')
        # TODO: puppetlabs-rabbitmq 4.1 doesn't support rabbitmq 3.4.0.
        #       Remove the following three lines after a new puppetlabs-rabbitmq release
        #       that contains PR #250
        shell('sed -i \'s/\(mirrorlist=http\)s/\1/\' /etc/yum.repos.d/epel.repo')
        shell('yum install -y erlang')
        shell('rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.3.5/rabbitmq-server-3.3.5-1.noarch.rpm')
      end
      shell('/bin/touch /etc/puppet/hiera.yaml')
      shell('puppet module install puppetlabs-stdlib --version 3.2.0', { :acceptable_exit_codes => [0] })
      shell('puppet module install maestrodev/wget --version 1.4.5', { :acceptable_exit_codes => [0] })
      shell('puppet module install puppetlabs/apt --version 1.6.0', { :acceptable_exit_codes => [0] })
      shell('puppet module install puppetlabs-rabbitmq --version 4.1.0', { :acceptable_exit_codes => [0] })
      shell('puppet module install fsalum-redis --version 1.0.0', { :acceptable_exit_codes => [0] })
      shell('puppet module install sensu-sensu', { :acceptable_exit_codes => [0] })
    end
  end
end
