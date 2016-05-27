module Pacemaker
  # this submodule contains "pcs" based common functions
  module PcsCommon
    # check if debug is enabled either in the pacemaker options
    # or the resource has the 'debug' parameter and it's enabled
    # @return [TrueClass,FalseClass]
    def debug_mode_enabled?
      return true if pacemaker_options[:debug_enabled]
      return true if @resource && @resource.parameters.keys.include?(:debug) && @resource[:debug]
      false
    end

    # safe pcs command
    # @param args [Array] command arguments
    # @return [String,NilClass]
    def pcs_safe(*args)
      command_line = (['pcs'] + args).join ' '
      if debug_mode_enabled?
        debug "Exec: #{command_line}"
        return
      end
      begin
        pcs *args
      rescue StandardError => exception
        debug "Command execution have failed: #{command_line}"
        raise exception
      end
    end

    # parse a list of "key: value" data to a hash
    # @param list [String]
    # @return [Hash]
    def pcs_list_to_hash(list)
      hash = {}
      list.split("\n").each do |line|
        line_arr = line.split ':'
        next unless line_arr.length == 2
        name = line_arr[0].chomp.strip
        value = line_arr[1].chomp.strip
        next if name.empty? || value.empty?
        value = false if value == 'false'
        value = true if value == 'true'
        hash.store name, value
      end
      hash
    end
  end
end
