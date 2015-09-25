#!/bin/bash
#############################################################################
# This script is executed on the remote AWS node to configure a test
# environment and ultimately run the test.
#############################################################################
GITREPO="$1"
GITBRANCH="$2"

# Install required repos and packages
wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian '$(lsb_release -cs)' contrib non-free' > /etc/apt/sources.list.d/virtualbox.list"
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install puppet git vagrant virtualbox-4.3
sudo modprobe vboxdrv

# Install RVM
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
echo progress-bar >> ~/.curlrc
curl -sSL https://get.rvm.io | bash -s stable --ruby
source $HOME/.rvm/scripts/rvm

# Clone the repo and let's do this!
echo "Cloning the $GITBRANCH branch from $GITREPO into workspace."
git clone -b $GITBRANCH $GITREPO workspace
cd workspace
gem install --no-rdoc bundler rake
bundle install --without development
bundle exec rake beaker
exit $?
