name 'razorsedge-snmp'
version '2.0.0'

author 'razorsedge'
license 'Apache License, Version 2.0'
project_page 'https://github.com/razorsedge/puppet-snmp'
source 'git://github.com/razorsedge/puppet-snmp.git'
summary 'Install and manage SNMP services.'
description 'This module manages the installation of the SNMP server, SNMP client, and SNMP trap server.  It also can create a SNMPv3 user with authentication and privacy passwords.'
dependency 'puppetlabs/stdlib', '>=2.3.0'
dependency 'razorsedge/lsb', '>=1.0.0'

# Generate the changelog file
system("git-log-to-changelog > CHANGELOG")
$? == 0 or fail "changelog generation #{$?}!"
