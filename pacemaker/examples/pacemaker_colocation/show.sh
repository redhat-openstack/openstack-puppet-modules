#!/bin/sh

show() {
  puppet resource pacemaker_colocation "${1}"
  cibadmin --query --xpath "/cib/configuration/constraints/rsc_colocation[@id='${1}']"
  echo '--------------------'
}

show 'colocation-test2_with_and_after_colocation-test1'
show 'colocation-test3_with_and_after_colocation-test1'
