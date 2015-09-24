#!/bin/sh
#############################################################################
# A shell script for running acceptance tests from travis via AWS.
#############################################################################

# Setup global variables and the execution environment.
set -e

FOG_RC=./secrets/fog.rc
export FOG_RC

#############################################################################
# Check if we are to run this at all.
#############################################################################

if [ -z "$BEAKER_TEST" ]; then
  echo "Skipping acceptance tests."
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
ruby tests/provision.rb

#############################################################################
# If we've got to this point, everything has worked OK.
#############################################################################
echo "Completed successfully."
exit 0
