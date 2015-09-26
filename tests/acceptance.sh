#!/bin/bash
#############################################################################
# A shell script for running acceptance tests from travis via AWS.
#############################################################################

# Setup global variables
export DEBUG=1
export EXCON_DEBUG=1
export FOG_RC=./secrets/fog.rc
export GITBRANCH='master'
export GITREPO='https://github.com/puppetlabs/puppetlabs-ntp.git'

#############################################################################
# Check if we are to run this at all.
#############################################################################

if [ -z "$BEAKER_TEST" ]; then
  echo "Skipping acceptance tests."
  exit 0
fi

if [ "$TRAVIS_BUILD_NUMBER" != 1 ]; then
  echo "Skipping because build number $TRAVIS_BUILD_NUMBER"
  exit 0
fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "This is a pull request, skipping acceptance tests."
  exit 0
fi

#############################################################################
# Provision the AWS node.
#############################################################################
tar xvf secrets.tar
instance_info=`ruby tests/provision.rb`
instance_id=`echo $instance_info | cut -d: -f1`
instance_public_ip_address=`echo $instance_info | cut -d: -f2`

# Strip whitespace
instance_id=`echo $instance_id`
instance_public_ip_address=`echo $instance_public_ip_address`

echo "Instance ID               : $instance_id"
echo "Instance Public IP Address: $instance_public_ip_address"

# Upload Payload
ssh_retries=10
ssh_attempt=1
sleep_period=10

while [ $ssh_attempt -lt $ssh_retries ]; do
  scp -i secrets/travis.pem -B -o "StrictHostKeyChecking no" tests/payload.sh \
    ubuntu@${instance_public_ip_address}:/var/tmp

  if [ $? -ne 0 ]; then
    echo "Attempt $ssh_attempt of $ssh_retries failed."
    echo "Will retry in $sleep_period seconds."
    sleep $sleep_period
  else
    break
  fi

  (( ssh_attempt = ssh_attempt + 1 ))
done

# Execute Payload
ssh -i ./secrets/travis.pem -o "StrictHostKeyChecking no" \
  ubuntu@${instance_public_ip_address} /var/tmp/payload.sh $GITREPO $GITBRANCH
status=$?

ruby tests/destroy.rb $instance_id
exit $status
