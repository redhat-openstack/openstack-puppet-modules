require_relative '../pacemaker_pcs'
require 'json'

Puppet::Type.type(:pacemaker_pcsd_auth).provide(:pcs, parent: Puppet::Provider::PacemakerPCS) do
  desc 'Authenticate the nodes using the "pcs" command'

  commands pcs: 'pcs'
  commands crm_node: 'crm_node'

  attr_reader :resource

  # these statuses are considered to be successful
  # @return [Array<String>]
  def success_node_statuses
    %w(already_authorized ok)
  end

  # checks if all nodes in the cluster are already authenticated,
  # or only the local one if :whole is not enabled
  # @return [true,false]
  def success
    validate_input
    nodes_status = cluster_auth

    success = whole_auth_success? nodes_status

    unless success or resource[:whole]
      success = local_auth_success? nodes_status
    end

    show_cluster_auth_status nodes_status
    success
  end

  # if the initial check was not successful
  # retry the auth command until it succeeds
  # or time runs out
  # @param value [true,false]
  def success=(value)
    # if the resource success value is not true don't do anything
    return unless value

    if resource[:whole]
      debug "Waiting #{max_wait_time} seconds for the whole cluster to authenticate"
    else
      debug "Waiting #{max_wait_time} seconds for the local node to authenticate"
    end

    # auth may succeed if the missing nodes come online
    # if password is not correct, wait for someone or something to change the password
    retry_block { success }

    if resource[:whole]
      debug 'The whole cluster authentication was successful!'
    else
      debug 'The local node have been successfully authenticated!'
    end
  end

  # show the debug block with the cluster auth status
  # @param nodes_status [Hash]
  def show_cluster_auth_status(nodes_status)
    message = "\nCluster auth status debug start\n"
    nodes_status.each do |node, status|
      success = success_node_statuses.include? status
      prefix = success ? 'OK  ' : 'FAIL'
      message += "#{prefix} #{node} (#{status})"
      message += ' <- this node' if node_name == node
      message += "\n"
    end
    message += 'Cluster auth status debug end'
    debug message
  end

  def validate_input
    fail 'Both username and password should be provided!' unless resource[:username] and resource[:password]
    resource[:nodes] = [resource[:nodes]] if resource[:nodes].is_a? String
    fail 'At least one node should be provided!' unless resource[:nodes].is_a? Array and resource[:nodes].any?
  end

  def cluster_auth
    debug 'Call: cluster_auth'
    result = pcs_auth_command(
        resource[:nodes],
        resource[:username],
        resource[:password],
        resource[:force],
        resource[:local],
    )
    nodes_status = pcs_auth_parse(result)
    fail "Could not parse the result of the cluster auth command: '#{result}'" unless nodes_status.is_a? Hash and nodes_status.any?
    nodes_status
  end

  # get the Pacemaker name of the current node
  # @return [String]
  def node_name
    return @node_name if @node_name
    @node_name = crm_node('-n').chomp.strip
  end

  # check if the local node auth have been successful
  # or was already done before
  # @param nodes_status [Hash]
  # @return [true,false]
  def local_auth_success?(nodes_status)
    success_node_statuses.include? nodes_status[node_name]
  end

  # check if all cluster nodes have been successfully authenticated
  # or have already been authenticated before
  # @param nodes_status [Hash]
  # @return [true,false]
  def whole_auth_success?(nodes_status)
    resource[:nodes].all? do |node|
      success_node_statuses.include? nodes_status[node]
    end
  end

end
