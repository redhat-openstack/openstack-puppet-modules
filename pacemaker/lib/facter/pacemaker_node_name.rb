require 'facter'

Facter.add('pacemaker_node_name') do
  setcode do
    Facter::Core::Execution.exec 'crm_node -n'
  end
end
