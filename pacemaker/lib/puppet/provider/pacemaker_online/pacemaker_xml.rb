require_relative '../pacemaker_xml'

Puppet::Type.type(:pacemaker_online).provide(:xml, parent: Puppet::Provider::PacemakerXML) do
  desc 'Use pacemaker library to wait for the cluster to become online before trying to do something with it.'

  commands cibadmin: 'cibadmin'
  commands crm_attribute: 'crm_attribute'

  # get the cluster status
  # @return [Symbol]
  def status
    if online?
      :online
    else
      :offline
    end
  end

  # wait for the cluster to become online
  # is status is set to :online
  # @param value [Symbol]
  def status=(value)
    wait_for_online 'pacemaker_online' if value == :online
  end
end
