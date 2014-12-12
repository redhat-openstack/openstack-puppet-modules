Puppet::Type.type(:pcmk_constraint).provide(:default) do
    desc 'A base constraint definition for a pacemaker constraint'

    ### overloaded methods
    def create
        case @resource[:constraint_type]
        when :location
            cmd = 'constraint location add ' + @resource[:name] + ' '  + @resource[:resource] + ' ' + @resource[:location] + ' ' + @resource[:score]
        when :colocation
            cmd = 'constraint colocation add ' + @resource[:resource] + ' with ' + @resource[:location] + ' ' + @resource[:score]
        else
            fail(String(@resource[:constraint_type]) + ' is an invalid location type')
        end

        # do pcs create
        pcs('create constraint', cmd)
    end

    def destroy
        case @resource[:constraint_type]
        when :location
            cmd = 'constraint location remove ' + @resource[:name]
        when :colocation
            cmd = 'constraint colocation remove ' + @resource[:resource] + ' ' + @resource[:location]
        end

        pcs('constraint delete', cmd)
    end

    def exists?
        cmd = 'constraint ' + String(@resource[:constraint_type]) + ' show --full'
        pcs_out = pcs('show', cmd)

        # find the constraint
        for line in pcs_out.lines.each do
            case @resource[:constraint_type]
            when :location
                return true if line.include? @resource[:name]
            when :colocation
                return true if line.include? @resource[:resource] + ' with ' + @resource[:location]
            end
        end
        # return false if constraint not found
        false
    end

    private

    def pcs(name, cmd)
        pcs_out = `/usr/sbin/pcs #{cmd}`
        #puts name
        #puts $?.exitstatus
        #puts pcs_out
        if $?.exitstatus != 0 and not name.include? 'show'
            if pcs_out.lines.first 
                raise Puppet::Error, "pcs #{name} failed: #{pcs_out.lines.first.chomp!}" if $?.exitstatus
            else
                raise Puppet::Error, "pcs #{name} failed" if $?.exitstatus
            end
        end
        # return output for good exit or false for failure.
        $?.exitstatus == 0 ? pcs_out : false
    end
end
