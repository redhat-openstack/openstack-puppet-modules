Puppet::Type.newtype(:pcmk_resource) do
    @doc = "Base resource definition for a pacemaker resource"

    ensurable

    newparam(:name) do
        desc "A unique name for the resource"
    end

    newparam(:resource_type) do
        desc "the pacemaker type to create"
    end
    newproperty(:resource_params) do
        desc "extra parameters to the retource group"
    end
    newproperty(:group) do
        desc "A resource group to put the resource in"
    end
    newproperty(:clone) do
        desc "set if this is a cloned resource"
        defaultto false
    end
    newproperty(:interval) do
        desc "resource check interval"
        defaultto "30s"
    end

end
