# == Class: contrail::provision_control
#
# Provision following 3 things
#
#   * control
#   * linklocal
#   * encap
#
# This class is simply an helper to be included when all three provisions needs
# to be done
#
class contrail::provision_control {

  include ::contrail::control::provision_control
  include ::contrail::control::provision_linklocal
  include ::contrail::control::provision_encap

}
