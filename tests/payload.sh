#!/bin/bash
#############################################################################
# This script is executed on the remote AWS node to configure a test
# environment and ultimately run the test.
#############################################################################
GITREPO="$1"
GITBRANCH="$2"

source $HOME/.rvm/scripts/rvm

# Clone the repo and let's do this!
echo "Cloning the $GITBRANCH branch from $GITREPO into workspace."
git clone -b $GITBRANCH $GITREPO workspace
cd workspace
gem install --no-rdoc bundler rake
bundle install --without development
status=0

for node in $( bundle exec rake beaker_nodes ); do
  BEAKER_set=$node bundle exec rake beaker

  if [ $? != 0 ]; then
    status=1
    break
  fi
done

exit $status
