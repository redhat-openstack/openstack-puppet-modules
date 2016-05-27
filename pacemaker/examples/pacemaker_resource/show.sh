#!/bin/sh

show() {
  puppet resource pacemaker_resource "${1}"
  cibadmin --query --xpath "/cib/configuration/resources/primitive[@id='${1}']"
  echo '--------------------'
}

show_clone() {
  puppet resource pacemaker_resource "${1}"
  cibadmin --query --xpath "/cib/configuration/resources/clone[@id='${1}-clone']"
  echo '--------------------'
}

show_master() {
  puppet resource pacemaker_resource "${1}"
  cibadmin --query --xpath "/cib/configuration/resources/master[@id='${1}-master']"
  echo '--------------------'
}

show 'test-simple1'
show 'test-simple2'
show 'test-simple-params1'
show 'test-simple-params2'
show_clone 'test-clone'
show_master 'test-master'
