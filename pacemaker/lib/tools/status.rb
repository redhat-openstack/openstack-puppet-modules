require_relative 'provider'

# This tool is like 'pcs status'. You can use it to view
# the status of the cluster as this library sees it
# using the debug output function.
#
# You can give it a dumped cib XML file for the first argument
# id you want to debug the code without Pacemaker running.

common = Puppet::Provider::PacemakerXML.new
if $ARGV[0] && File.exist?($ARGV[0])
  xml = File.read $ARGV[0]
  common.cib = xml
end

common.cib
puts common.cluster_debug_report
