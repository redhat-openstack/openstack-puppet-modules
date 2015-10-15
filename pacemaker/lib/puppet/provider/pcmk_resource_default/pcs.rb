# Currently the implementation is somewhat naive (will not work great
# with ensure => absent, unless the correct current value is also
# specified). For more proper handling, prefetching should be
# implemented and `value` should be switched from a param to a
# property. This should be possible to do without breaking the
# interface of the resource type.
Puppet::Type.type(:pcmk_resource_default).provide(:pcs) do
  desc 'Manages default values for pacemaker resource options via pcs'

  def create
    name = @resource[:name]
    value = @resource[:value]

    cmd = "resource defaults #{name}='#{value}'"

    pcs(cmd)
  end

  def destroy
    name = @resource[:name]

    cmd = 'resource defaults #{name}='
    pcs(cmd)
  end

  def exists?
    name = @resource[:name]
    value = @resource[:value]

    cmd = 'resource defaults'
    status, _ = pcs(cmd,
                    :grep => "^#{name}: #{value}$",
                    :allow_failure => true)
    status == 0
  end

  def pcs(cmd, options={})
    full_cmd = "pcs #{cmd}"

    if options[:grep]
      full_cmd += " | grep '#{options[:grep]}'"
    end

    Puppet.debug("Running #{full_cmd}")
    output = `#{full_cmd}`
    status = $?.exitstatus

    if status != 0 && !options[:allow_failure]
      raise Puppet::Error("#{full_cmd} returned #{status}, output: #{output}")
    end

    [status, output]
  end
end
