Puppet::Type.type(:pcmk_resource).provide(:default) do
    desc 'A base resource definition for a pacemaker resource'

    ### overloaded methods
    def create
        cmd = 'resource create ' + @resource[:name] + ' ' + @resource[:resource_type] + ' ' + @resource[:resource_params] + ' op monitor interval=' + @resource[:interval]
        if @resource[:monitor_params] and not @resource[:monitor_params].empty?
            cmd += hash_to_params(@resource[:monitor_params])
        end
        # group defaults to empty
        if not @resource[:group].empty?
            cmd += ' --group ' + @resource[:group]
        end
        # clone defaults to false
        if @resource[:clone]
            cmd += ' --clone'
        end
        # do pcs create
        pcs('create', cmd)
    end

    def destroy
        cmd = 'resource delete ' + @resource[:name]
        pcs('delete', cmd)
    end

    def exists?
        cmd = 'resource show ' + @resource[:name] + ' > /dev/null 2>&1'
        pcs('show', cmd)
    end


    ### property methods
    def resource_params
        cmd = 'resource show ' + @resource[:name]
        get_attrs = pcs('get interval', cmd)

        # find the Attributes
        for line in get_attrs.lines.each do
            return (line.scan /Attributes: (.+?)$/m)[0][0].strip if line.include? 'Attributes:'
        end
        # return empty string if Attributes not found
        ''
    end

    def resource_params=(value)
        cmd = 'resource update ' + @resource[:name] + ' ' + value
        pcs('update attributes', cmd)
    end

    def group
        # get the list of groups and their resources
        cmd = 'resource --groups'
        resource_groups = pcs('group list', cmd)

        # find the group that has the resource in it
        for group in resource_groups.lines.each do
            return group[0, /:/ =~ group] if group.include? @resource[:name]
        end
        # return empty string if a group wasn't found
        # that includes the resource in it.
        ''
    end

    def group=(value)
        if value.empty?
            cmd = 'resource ungroup ' + group + ' ' + @resource[:name]
            pcs('ungroup', cmd)
        else
            cmd = 'resource group add ' + value + ' ' + @resource[:name]
            pcs('group add', cmd)
        end
    end

    def clone
        cmd = 'resource show ' + @resource[:name] + '-clone > /dev/null 2>&1'
        pcs('show clone', cmd) == false ? false : true
    end

    def clone=(value)
        if not value
            cmd = 'resource unclone ' + @resource[:name]
            pcs('unclone', cmd)
        else
            cmd = 'resource clone ' + @resource[:name]
            pcs('clone', cmd)
        end
    end

    def interval
        cmd = 'resource show ' + @resource[:name]
        get_interval = pcs('get interval', cmd)

        # find the interval value
        for line in get_interval.lines.each do
            return (line.scan /interval=(.+?) /m)[0][0] if line.include? 'interval='
        end
        # return empty string if an interval value wasn't found
        ''
    end

    def interval=(value)
        cmd = 'resource update ' + @resource[:name] + ' op monitor interval=' + value
        pcs('update interval', cmd)
    end

    def monitor_params
        cmd = 'resource show ' + @resource[:name]
        pcs_output = pcs('get monitor params', cmd)

        pcs_output.each_line do |line|
            line.strip.match(/(Operations: )?monitor ([^(]+)/) do |match|
                Puppet.debug(match.inspect)
                return params_to_hash(match[2])
            end
        end
        # return empty string if monitor params not found
        ''
    end

    def monitor_params=(value)
        cmd = 'resource update ' + @resource[:name] + ' op monitor ' + hash_to_params(value)
        pcs('update interval', cmd)
    end

    private

    def pcs(name, cmd)
        Puppet.debug("/usr/sbin/pcs #{cmd}")
        pcs_out = `/usr/sbin/pcs #{cmd}`
        #puts name
        #puts $?.exitstatus
        if $?.exitstatus != 0 and pcs_out.lines.first and not name.include? 'show'
            Puppet.debug("Error: #{pcs_out}")
            raise Puppet::Error, "pcs #{name} failed: #{pcs_out.lines.first.chomp!}" if $?.exitstatus
        end
        # return output for good exit or false for failure.
        $?.exitstatus == 0 ? pcs_out : false
    end

    def params_to_hash(str)
        str.split.reduce({}) do |hash, param|
            k,v = param.split '='
            hash[k] = v
            hash
        end
    end

    def hash_to_params(hash)
        params = ''
        hash.each_pair do |k,v|
            params += " #{k}=#{v}"
        end
        params
    end
end
