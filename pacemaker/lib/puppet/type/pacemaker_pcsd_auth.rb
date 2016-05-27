require 'puppet/parameter/boolean'
require 'puppet/property/boolean'

Puppet::Type.newtype(:pacemaker_pcsd_auth) do
  desc <<-eof
Use the "pcs" command to authenticate nodes in each other's "pcsd" daemon so the cluster can be managed.
This is a "singleton" type, usually there is no need to have several instances of it in a single catalog.

But, if you have serious reasons to, you can have many instances of this type with different sets
of cluster nodes or other parameters.
  eof

  newparam(:name) do
    isnamevar
  end

  newproperty(:success, boolean: true, parent: Puppet::Property::Boolean) do
    desc <<-eof
Should the auth succeed? The value of this property should be true.
Setting it to false will disable the retry loop that waits for the
auth success.
    eof

    isrequired
    defaultto true
  end

  newparam(:nodes, array_matching: :all) do
    desc <<-eof
The list of cluster nodes to authenticate.
The retrieved values would be the list of successfully authenticated nodes.
Order of the nodes list does not matter.
    eof

    isrequired
    defaultto []
  end

  newparam(:username) do
    desc <<-eof
Use this user to access the nodes
Default: hacluster
    eof

    isrequired
    defaultto 'hacluster'
  end

  newparam(:password) do
    desc <<-eof
Use this user to access the nodes
    eof

    isrequired
  end

  newparam(:force, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-eof
Re-authenticate nodes on each run even if they are already authenticated.
    eof

    isrequired
    defaultto false
  end

  newparam(:local, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-eof
Don't authenticate all the nodes to each other. Authenticate only the local node.
It may be helpful if the other cluster nodes are not online.
Requires the 'whole' parameter to be set to false.
    eof

    isrequired
    defaultto false
  end

  newparam(:whole, boolean: true, parent: Puppet::Parameter::Boolean) do
    desc <<-eof
Consider authentication successful only if the whole cluster have been authenticated,
or the local node alone is enough to continue the deployment. Other nodes may come online later.
    eof

    isrequired
    defaultto true
  end

  autorequire(:service) do
    %w(pcsd)
  end

  # if this resource receives the notify event
  # (likely from a User type or from something that have set the user password)
  # force the re-authentication of the cluster nodes
  def refresh
    debug 'Forcing the re-authentication of the cluster nodes'
    self[:force] = true
    provider.success = self[:success] unless provider.success
  end

end
