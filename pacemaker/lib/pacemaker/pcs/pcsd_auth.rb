module Pacemaker
  # this submodule contains "pcs" based function for cluster property provider
  module PcsPcsdAuth
    # run the 'pcs cluster auth' command and capture
    # the debug output, returned by the pcsd.cli ruby tool
    # returns nil if could not get the data
    # @param nodes [Array<String>] the list of cluster nodes top auth
    # @param username [String]
    # @param password [String]
    # @param force [String] auth even if already have been auth'ed
    # @param local [String] auth only the local node
    # @return [String,nil]
    def pcs_auth_command(nodes, username, password, force=false, local=false)
      command = %w(cluster auth --debug)
      command << '--force' if force
      command << '--local' if local
      command += [ '-u', username ]
      command += [ '-p', password ]
      command += [nodes]
      command.flatten!

      begin
        output = pcs *command
      rescue Puppet::ExecutionFailure => e
        output = e.to_s
      end

      return unless output
      inside_debug_block = false
      result = []
      output.split("\n").each do |line|
        inside_debug_block = false if line == '--Debug Output End--'
        result << line if inside_debug_block
        inside_debug_block = true if line == '--Debug Output Start--'
      end
      return unless result.any?
      result.join("\n")
    end

    # parse the debug output of the pcs auth command
    # to a hash of nodes and their statuses
    # returns nil on error
    # @param result [String]
    # @return [Hash<String => String>,nil]
    def pcs_auth_parse(result)
      result_structure = begin
        JSON.load result
      rescue StandardError
        nil
      end
      return unless result_structure.is_a? Hash
      responses = result_structure.fetch('data', {}).fetch('auth_responses', {})
      status_hash = {}
      responses.each do |node, response|
        next unless response.is_a? Hash
        node_status = response['status']
        next unless node_status
        status_hash.store node, node_status
      end
      status_hash
    end

  end
end
