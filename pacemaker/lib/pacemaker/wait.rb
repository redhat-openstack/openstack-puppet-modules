module Pacemaker
  # functions that can wait for something repeatedly
  # polling the system status until the condition is met
  module Wait
    # retry the given command until it runs without errors
    # or for RETRY_COUNT times with RETRY_STEP sec step
    # print cluster status report on fail
    # @param options [Hash]
    def retry_block(options = {})
      options = pacemaker_options.merge options

      options[:retry_count].times do
        begin
          out = Timeout.timeout(options[:retry_timeout]) { yield }
          if options[:retry_false_is_failure]
            return out if out
          else
            return out
          end
        rescue => e
          debug "Execution failure: #{e.message}"
        end
        sleep options[:retry_step]
      end
      raise "Execution timeout after #{options[:retry_count] * options[:retry_step]} seconds!" if options[:retry_fail_on_timeout]
    end

    # wait for pacemaker to become online
    # @param comment [String] log tag comment to trace calls
    def wait_for_online(comment = nil)
      message = "Waiting #{max_wait_time} seconds for Pacemaker to become online"
      message += " (#{comment})" if comment
      debug message
      retry_block { online? }
      debug 'Pacemaker is online'
    end

    # wait until a primitive has known status
    # @param primitive [String] primitive name
    # @param node [String] on this node if given
    def wait_for_status(primitive, node = nil)
      message = "Waiting #{max_wait_time} seconds for a known status of '#{primitive}'"
      message += " on node '#{node}'" if node
      debug message
      retry_block do
        cib_reset 'wait_for_status'
        !primitive_status(primitive).nil?
      end
      message = "Primitive '#{primitive}' has status '#{primitive_status primitive}'"
      message += " on node '#{node}'" if node
      debug message
    end

    # wait for primitive to start
    # if node is given then start on this node
    # @param primitive [String] primitive id
    # @param node [String] on this node if given
    def wait_for_start(primitive, node = nil)
      message = "Waiting #{max_wait_time} seconds for the service '#{primitive}' to start"
      message += " on node '#{node}'" if node
      debug message
      retry_block do
        cib_reset 'wait_for_start'
        primitive_is_running? primitive, node
      end
      message = "Service '#{primitive}' have started"
      message += " on node '#{node}'" if node
      debug message
    end

    # wait for primitive to start as a master
    # if node is given then start as a master on this node
    # @param primitive [String] primitive id
    # @param node [String] on this node if given
    def wait_for_master(primitive, node = nil)
      message = "Waiting #{max_wait_time} seconds for the service '#{primitive}' to start master"
      message += " on node '#{node}'" if node
      debug message
      retry_block do
        cib_reset 'wait_for_master'
        primitive_has_master_running? primitive, node
      end
      message = "Service '#{primitive}' have started master"
      message += " on node '#{node}'" if node
      debug message
    end

    # wait for primitive to stop
    # if node is given then start on this node
    # @param primitive [String] primitive id
    # @param node [String] on this node if given
    def wait_for_stop(primitive, node = nil)
      message = "Waiting #{max_wait_time} seconds for the service '#{primitive}' to stop"
      message += " on node '#{node}'" if node
      debug message
      retry_block do
        cib_reset 'wait_for_stop'
        result = primitive_is_running? primitive, node
        result.is_a? FalseClass
      end
      message = "Service '#{primitive}' was stopped"
      message += " on node '#{node}'" if node
      debug message
    end

    # add a new primitive to CIB
    # and wait for it to be actually created
    # @param xml [String, REXML::Element] XML block to add
    # @param primitive [String] the id of the new primitive
    # @param scope [String] XML root scope
    def wait_for_primitive_create(xml, primitive, scope = 'resources')
      message = "Waiting #{max_wait_time} seconds for the primitive '#{primitive}' to be created"
      debug message
      retry_block do
        if pacemaker_options[:cibadmin_idempotency_checks]
          cib_reset 'wait_for_primitive_create'
          break true if primitive_exists? primitive
        end
        cibadmin_create xml, scope
      end
      message = "Primitive '#{primitive}' was created"
      debug message
    end

    # remove a primitive from CIB
    # and wait for it to be actually removed
    # @param xml [String, REXML::Element] XML block to remove
    # @param primitive [String] the id of the removed primitive
    # @param scope [String] XML root scope
    def wait_for_primitive_remove(xml, primitive, scope = 'resources')
      message = "Waiting #{max_wait_time} seconds for the primitive '#{primitive}' to be removed"
      debug message
      retry_block do
        if pacemaker_options[:cibadmin_idempotency_checks]
          cib_reset 'wait_for_primitive_remove'
          break true unless primitive_exists? primitive
        end
        cibadmin_delete xml, scope
      end
      message = "Primitive '#{primitive}' was removed"
      debug message
    end

    # update a primitive in CIB
    # and wait for it to be actually updated
    # @param xml [String, REXML::Element] XML block to update
    # @param primitive [String] the id of the updated primitive
    # @param scope [String] XML root scope
    def wait_for_primitive_update(xml, primitive, scope = 'resources')
      message = "Waiting #{max_wait_time} seconds for the primitive '#{primitive}' to be updated"
      debug message
      retry_block do
        # replace action is already idempotent
        cibadmin_replace xml, scope
      end
      message = "Primitive '#{primitive}' was updated"
      debug message
    end

    # add a new constraint to CIB
    # and wait for it to be actually created
    # @param xml [String, REXML::Element] XML block to add
    # @param constraint [String] the id of the new constraint
    # @param scope [String] XML root scope
    def wait_for_constraint_create(xml, constraint, scope = 'constraints')
      message = "Waiting #{max_wait_time} seconds for the constraint '#{constraint}' to be created"
      debug message
      retry_block do
        if pacemaker_options[:cibadmin_idempotency_checks]
          cib_reset 'wait_for_constraint_create'
          break true if constraint_exists? constraint
        end
        cibadmin_create xml, scope
      end
      message = "Constraint '#{constraint}' was created"
      debug message
    end

    # remove a constraint from CIB
    # and wait for it to be actually removed
    # @param xml [String, REXML::Element] XML block to remove
    # @param constraint [String] the id of the removed constraint
    # @param scope [String] XML root scope
    def wait_for_constraint_remove(xml, constraint, scope = 'constraints')
      message = "Waiting #{max_wait_time} seconds for the constraint '#{constraint}' to be removed"
      debug message
      retry_block do
        if pacemaker_options[:cibadmin_idempotency_checks]
          cib_reset 'wait_for_constraint_remove'
          break true unless constraint_exists? constraint
        end
        cibadmin_delete xml, scope
      end
      message = "Constraint '#{constraint}' was removed"
      debug message
    end

    # update a constraint in CIB
    # and wait for it to be actually updated
    # @param xml [String, REXML::Element] XML block to update
    # @param constraint [String] the id of the updated constraint
    # @param scope [String] XML root scope
    def wait_for_constraint_update(xml, constraint, scope = 'constraints')
      message = "Waiting #{max_wait_time} seconds for the constraint '#{constraint}' to be updated"
      debug message
      retry_block do
        # replace action is already idempotent
        cibadmin_replace xml, scope
      end
      message = "Constraint '#{constraint}' was updated"
      debug message
    end

    # check if pacemaker is online and we can work with it
    # * pacemaker is online if cib can be downloaded
    # * dc_version attribute can be obtained
    # * DC have been designated
    # Times out a stuck command calls and catches failed command calls
    # @return [TrueClass,FalseClass]
    def online?
      Timeout.timeout(pacemaker_options[:retry_timeout]) do
        return false unless dc_version
        return false unless dc
        return false unless cib_section_node_state
        true
      end
    rescue Puppet::ExecutionFailure => e
      debug "Cluster is offline: #{e.message}"
      false
    rescue Timeout::Error
      debug 'Online check timeout!'
      false
    end
  end
end
