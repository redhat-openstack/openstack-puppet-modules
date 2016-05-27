#!/bin/sh

show() {
  puppet resource pacemaker_operation_default "${1}"
  cibadmin --query --xpath "/cib/configuration/op_defaults/meta_attributes/nvpair[@name='${1}']"
  echo '--------------------'
}

show 'interval'
