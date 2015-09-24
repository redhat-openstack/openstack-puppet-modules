require 'rubygems'
require 'fog'

# create a connection
ec2 = Fog::Compute.new({
  :provider                 => 'AWS',
  :region                   => 'eu-west-1',
})

response = ec2.run_instances(
  'ami-47a23a30',
  1,
  1,
  'InstanceType'  => 't2.micro',
  'SecurityGroup' => 'ssh',
  'KeyName'       => 'travis'
)

instance_id = response.body["instancesSet"].first["instanceId"]
instance = ec2.servers.get(instance_id)
instance.wait_for { ready? }
puts instance.public_ip_address
