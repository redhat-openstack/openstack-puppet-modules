name 'razorsedge-snmp'
version '1.0.2'

author 'razorsedge'
license 'Apache License, Version 2.0'
project_page 'https://github.com/razorsedge/puppet-snmp'
source 'git://github.com/razorsedge/puppet-snmp.git'
summary 'Install and manage SNMP services.'
description 'This module manages the installation of the SNMP server, SNMP client, and SNMP trap server.  It also can create a SNMPv3 user with authentication and privacy passwords.'

# Generate the changelog file
system("git-log-to-changelog > CHANGELOG")
$? == 0 or fail "changelog generation #{$?}!"
