#!/bin/bash
# Based on the great work by purple52
# https://github.com/purple52/librarian-puppet-vagrant

PUPPET_DIR=/etc/puppet/
OPERATING_SYSTEM=$(facter operatingsystem)

redhat () {
    if ! rpm -qa git &> /dev/null; then
        yum -qy makecache
        yum -qy install git
    fi
}

debian () {
    if ! dpkg -s git &> /dev/null ||
        ! dpkg -s ruby-dev &> /dev/null; then
        apt-get -qq update
        apt-get -qq install git ruby-dev
    fi
}

case $OPERATING_SYSTEM in
    'RedHat' | 'CentOS' )
        redhat
        ;;
    'Debian' | 'Ubuntu' )
        debian
        ;;
esac

if [ ! -d "$PUPPET_DIR" ]; then
    mkdir -p $PUPPET_DIR
fi
cp /vagrant/Puppetfile $PUPPET_DIR

if [ "$(gem search -i r10k)" = "false" ]; then
    gem install -q r10k --no-ri --no-rdoc
fi
cd $PUPPET_DIR && r10k puppetfile install #--verbose
