require 'puppet/parameter/boolean'

Puppet::Type.newtype(:pcmk_resource) do
  @doc = "Base resource definition for a pacemaker resource"

  ensurable

  newparam(:name) do
    desc "A unique name for the resource"
  end
  newparam(:resource_type) do
    desc "the pacemaker type to create"
  end

  newparam(:post_success_sleep) do
    desc "The time to sleep after successful pcs action.  The reason to set
          this is to avoid immediate back-to-back 'pcs resource create' calls
          when creating multiple resources.  Defaults to '0'."

    munge do |value|
      if value.is_a?(String)
        unless value =~ /^[-\d.]+$/
          raise ArgumentError, "post_success_sleep must be a number"
        end
        value = Float(value)
      end
      raise ArgumentError, "post_success_sleep cannot be a negative number" if value < 0
      value
    end

    defaultto 0
  end

  ## borrowed from exec.rb
  newparam(:tries) do
    desc "The number of times to attempt to create a pcs resource.
      Defaults to '1'."

    munge do |value|
      if value.is_a?(String)
        unless value =~ /^[\d]+$/
          raise ArgumentError, "Tries must be an integer"
        end
        value = Integer(value)
      end
      raise ArgumentError, "Tries must be an integer >= 1" if value < 1
      value
    end

    defaultto 1
  end

  newparam(:try_sleep) do
    desc "The time to sleep in seconds between 'tries'."

    munge do |value|
      if value.is_a?(String)
        unless value =~ /^[-\d.]+$/
          raise ArgumentError, "try_sleep must be a number"
        end
        value = Float(value)
      end
      raise ArgumentError, "try_sleep cannot be a negative number" if value < 0
      value
    end

    defaultto 0
  end

  newparam(:verify_on_create, :boolean => true, :parent => Puppet::Parameter::Boolean) do
     desc "Whether to verify pcs resource creation with an additional
     call to 'pcs resource show' rather than just relying on the exit
     status of 'pcs resource create'.  When true, $try_sleep
     determines how long to wait to verify and $post_success_sleep is
     ignored.  Defaults to `false`."

     defaultto false
   end

  newproperty(:op_params) do
    desc "op parameters"
  end
  newproperty(:meta_params) do
    desc "meta parameters"
  end
  newproperty(:resource_params) do
    desc "resource parameters"
  end
  newproperty(:clone_params) do
    desc "clone params"
  end
  newproperty(:group_params) do
    desc "A resource group to put the resource in"
  end
  newproperty(:master_params) do
    desc "set if this is a cloned resource"
  end

end
