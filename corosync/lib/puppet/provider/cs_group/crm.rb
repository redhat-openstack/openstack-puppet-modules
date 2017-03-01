require 'pathname'
require Pathname.new(__FILE__).dirname.dirname.expand_path + 'crmsh'

Puppet::Type.type(:cs_group).provide(:crm, :parent => Puppet::Provider::Crmsh) do
  desc 'Provider to add, delete, manipulate primitive groups.'

  # Path to the crm binary for interacting with the cluster configuration.
  commands :crm => '/usr/sbin/crm'

  def self.instances

    block_until_ready

    instances = []

    cmd = [ command(:crm), 'configure', 'show', 'xml' ]
    if Puppet::PUPPETVERSION.to_f < 3.4
      raw, status = Puppet::Util::SUIDManager.run_and_capture(cmd)
    else
      raw = Puppet::Util::Execution.execute(cmd)
      status = raw.exitstatus
    end
    doc = REXML::Document.new(raw)

    REXML::XPath.each(doc, '//group') do |e|

      items = e.attributes
      group = { :name => items['id'].to_sym }

      primitives = []

      if ! e.elements['primitive'].nil?
        e.each_element do |p|
          primitives << p.attributes['id']
        end
      end

      group_instance = {
        :name       => group[:name],
        :ensure     => :present,
        :primitives => primitives,
        :provider   => self.name
      }
      instances << new(group_instance)
    end
    instances
  end

  # Create just adds our resource to the property_hash and flush will take care
  # of actually doing the work.
  def create
    @property_hash = {
      :name       => @resource[:name],
      :ensure     => :present,
      :primitives => @resource[:primitives]
    }
    @property_hash[:cib] = @resource[:cib] if ! @resource[:cib].nil?
  end

  # Unlike create we actually immediately delete the item but first, like primitives,
  # we need to stop the group.
  def destroy
    debug('Stopping group before removing it')
    crm('resource', 'stop', @resource[:name])
    debug('Revmoving group')
    crm('configure', 'delete', @resource[:name])
    @property_hash.clear
  end

  # Getter that obtains the primitives array for us that should have
  # been populated by prefetch or instances (depends on if your using
  # puppet resource or not).
  def primitives
    @property_hash[:primitives]
  end

  # Our setters for the primitives array and score.  Setters are used when the
  # resource already exists so we just update the current value in the property
  # hash and doing this marks it to be flushed.
  def primitives=(should)
    @property_hash[:primitives] = should.sort
  end

  # Flush is triggered on anything that has been detected as being
  # modified in the property_hash.  It generates a temporary file with
  # the updates that need to be made.  The temporary file is then used
  # as stdin for the crm command.
  def flush
    unless @property_hash.empty?
      updated = 'group '
      updated << "#{@property_hash[:name]} #{@property_hash[:primitives].join(' ')}"
      Tempfile.open('puppet_crm_update') do |tmpfile|
        tmpfile.write(updated)
        tmpfile.flush
        ENV['CIB_shadow'] = @resource[:cib]
        crm('configure', 'load', 'update', tmpfile.path.to_s)
      end
    end
  end
end
