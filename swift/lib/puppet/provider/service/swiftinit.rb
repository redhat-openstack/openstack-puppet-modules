# swift-init service management
#
# author Adam Vinsh <adam.vinsh@twcable.com>
Puppet::Type.type(:service).provide :swiftinit, :parent => :service do
  desc 'Manage swift services using swift-init'

  has_feature :enableable
  has_feature :refreshable

  confine :any => [
    Facter.value(:osfamily) == 'Debian',
    Facter.value(:osfamily) == 'RedHat'
  ]

  # Check if swift service is running using swift-init
  def status
    if swiftinit_run('status', false).exitstatus == 0
      return :running
    else
      # Transition block for systemd systems.  If swift-init reports service is
      # not running then send stop to systemctl so that service can be started
      # with swift-init and fully managed by this provider.
      if Facter.value(:operatingsystem) != 'Ubuntu'
        systemctl_run('stop', [resource[:pattern]], false)
        systemctl_run('disable', [resource[:pattern]], false)
      end
      return :stopped
    end
  end

  # Start this swift service using swift-init
  def start
    swiftinit_run('start', true)
  end

  # Stop this swift service using swift-init allowing
  # current requests to finish on supporting servers
  def stop
    swiftinit_run('shutdown', true)
  end

  # Restart this swift service using swift-init reload,
  # graceful shutdown then restart on supporting servers
  def restart
    swiftinit_run('reload', true)
  end

  def refresh
    if (@paramaters[:ensure] == running)
      provider.restart
    else
      debug 'Skipping restart, service is not running'
    end
  end

  # Returns service enabled status using systemctl on Redhat/Debian
  # and using presence of init file on Ubuntu.
  def enabled?
    if Facter.value(:operatingsystem) != 'Ubuntu'
      if Puppet::FileSystem.exist?("/etc/systemd/system/#{resource[:pattern]}.service")
        if systemctl_run('is-enabled', [resource[:pattern]], false).exitstatus == 0
          return :true
        end
      else
        return :false
      end
    elsif Facter.value(:operatingsystem) == 'Ubuntu'
      if Puppet::FileSystem.exist?("/etc/init/#{resource[:pattern]}.conf")
        return :true
      else
        return :false
      end
    end
  end

  # Enable the service at boot.  For Redhat and Debian create services
  # file and notify systemctl.  For Ubuntu create init file.
  def enable
    if Facter.value(:operatingsystem) != 'Ubuntu'
      file = Puppet::Type.type(:file).new(
        :name    => "/etc/systemd/system/#{resource[:pattern]}.service",
        :ensure  => :present,
        :content => systemd_template,
        :mode    => '0644'
      )
      file.write(file)
      systemctl_run('daemon-reload', nil, true)
      systemctl_run('enable', [resource[:pattern]], false)
    elsif Facter.value(:operatingsystem) == 'Ubuntu'
      file = Puppet::Type.type(:file).new(
        :name    => "/etc/init/#{resource[:pattern]}.conf",
        :ensure  => :present,
        :content => upstart_template,
        :mode    => '0644'
      )
      file.write(file)
    end
  end

  # Disable the service at boot. For Redhat and Debain,
  # delete services file and notify systemctl.  For Ubuntu
  # remove init file.
  def disable
    if Facter.value(:operatingsystem) != 'Ubuntu'
      systemctl_run('disable', [resource[:pattern]], false)
      File.delete("/etc/systemd/system/#{resource[:pattern]}.service")
      systemctl_run('daemon-reload', nil, true)
    elsif Facter.value(:operatingsystem) == 'Ubuntu'
      File.delete("/etc/init/#{resource[:pattern]}.conf")
    end
  end

  # Wrapper to handle swift-init calls on supported osfamily
  def swiftinit_run(command, failonfail)
    execute([['swift-init'], ["#{type}-#{subtype}#{manifest}"], [command]],
            :failonfail => failonfail)
  rescue Puppet::ExecutionFailure => detail
    @resource.fail Puppet::Error,
                   "swift-init #{type}-#{subtype}#{manifest} #{command}
                   failed with: #{@resource.ref}: #{detail}", detail
  end

  # Wrapper to handle systemctl calls on supported osfamily
  def systemctl_run(command, unit_file, failonfail)
    if unit_file
      execute([['systemctl'], [command], [unit_file]], :failonfail => failonfail)
    else
      execute([['systemctl'], [command]], :failonfail => failonfail)
    end
  rescue Puppet::ExecutionFailure => detail
    @resource.fail Puppet::Error,
                   "systemctl #{command} #{unit_file}
                   failed with: #{@resource.ref}: #{detail}", detail
  end

  # Split the service type off of name
  # type can be object, account, container.
  def type
    resource[:name].split(/-/)[1]
  end

  # Split the service subtype off of name
  # subtype can be:
  # For type account:   auditor, reaper, replicator, server.
  # For type container: auditor, replicator, server, sync, updater.
  # For type object:    auditor, replicator, server, updater, expirer.
  # For type proxy:     server.
  def subtype
    resource[:name].split(/-/)[2]
  end

  # In this provider 'manifest' is the name of the config file that the service
  # uses to run. If the config file is a default name ex: object-server.conf.
  # then swift-init can be called without specifying the config file.
  # TODO add logic to start servers using multiple config files, used to run
  # swift with a dedicated replication network.
  def manifest
    if "#{resource[:manifest]}" == "#{type}-server.conf"
      return nil
    elsif "#{resource[:manifest]}" == 'object-expirer.conf'
      return nil
    else return ".#{resource[:manifest].split('.conf')[1]}"
    end
  end

  # Begin service template boot section.
  def upstart_template
    %(# swift-#{type}-#{subtype}
#
# Starts the swift-#{type}-#{subtype}.

description     "SWIFT #{type} #{subtype}"
author          "Puppet"

start on runlevel [2345]
stop on runlevel [016]

pre-start script
if [ -f /etc/swift/#{resource[:manifest]} ]; then
  exec /usr/bin/swift-init #{type}-#{subtype} start
else
  exit 1
fi
end script

post-stop exec /usr/bin/swift-init #{type}-#{subtype} stop)
  end

  def systemd_template
    %([Unit]
Description=OpenStack "SWIFT #{type} #{subtype}"
After=syslog.target network.target

[Service]
Type=forking
User=root
ExecStart=/usr/bin/swift-init #{type}-#{subtype} start

[Install]
WantedBy=multi-user.target)
  end
end
