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

echo "TRAVIS_BUILD_ID     : $TRAVIS_BUILD_ID"
echo "TRAVIS_BUILD_NUMBER : $TRAVIS_BUILD_ID"
echo "TRAVIS_JOB_ID       : $TRAVIS_JOB_ID"
echo "TRAVIS_JOB_NUMBER   : $TRAVIS_JOB_NUMBER"
echo "TRAVIS_TEST_RESULT  : $TRAVIS_TEST_RESULT"

#############################################################################
# Check if we are to run this at all.
#############################################################################

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "This is a pull request, skipping acceptance tests."
  exit 0
fi

sub_job_number=$( echo $TRAVIS_JOB_NUMBER | cut -d. -f2 )

if [ "$sub_job_number" != 1 ]; then
  echo "Skipping acceptance tests."
  exit 0
fi

if [ "$TRAVIS_TEST_RESULT" != 0 ]; then
  echo "Travis has already detected a failure."
  echo "Skipping acceptance tests."
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
