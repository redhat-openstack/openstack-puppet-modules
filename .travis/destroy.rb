require 'rubygems'
require 'fog'

# create a connection
ec2 = Fog::Compute.new({
  :provider                 => 'AWS',
  :region                   => 'eu-west-1',
})

instance_id = ARGV[0]
instance = ec2.servers.get(instance_id)
instance.destroy
instance.wait_for {state == 'terminated'} 
