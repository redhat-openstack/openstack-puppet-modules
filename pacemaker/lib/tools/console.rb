require_relative 'provider'
require 'pry'

# This console can be used to debug the pacemaker library
# and its methods or for the manual control over the cluster.
#
# It requires 'pry' gem to be installed.
#
# You can give it a dumped cib XML file for the first argument
# id you want to debug the code without Pacemaker running.

common = Puppet::Provider::PacemakerXML.new
if $ARGV[0] && File.exist?($ARGV[0])
  xml = File.read $ARGV[0]
  common.cib = xml
end

common.pry
