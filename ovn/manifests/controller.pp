# ovn controller
# == Class: ovn::controller
#
# installs ovn and starts the ovn-controller service
#
# === Parameters:
#
# [*ovn_remote*]
#   (Required) URL of the remote ovsdb-server that manages ovn-nb and ovn-sb dbs
#
# [*ovn_encap_type*]
#   (Optional) The encapsulation type to be used
#   Defaults to 'geneve'
#
# [*ovn_encap_ip*]
#   (Required) IP address of the hypervisor(in which this module is installed) to which
#   the other controllers would use to create a tunnel to this controller
#
class ovn::controller(
    $ovn_remote,
    $ovn_encap_ip,
    $ovn_encap_type = 'geneve',
) {
    include ::ovn::params
    include ::vswitch::ovs
    include ::stdlib

    validate_string($ovn_remote)
    validate_string($ovn_encap_ip)

    service { 'controller':
        ensure    => true,
        name      => $::ovn::params::ovn_controller_service_name,
        hasstatus => $::ovn::params::ovn_controller_service_status,
        pattern   => $::ovn::params::ovn_controller_service_pattern,
        enable    => true,
        require   => [Vs_config['external_ids:ovn-remote'],
                      Vs_config['external_ids:ovn-encap-type'],
                      Vs_config['external_ids:ovn-encap-ip']]
    }

    package { $::ovn::params::ovn_controller_package_name:
        ensure => present,
        name   => $::ovn::params::ovn_controller_package_name,
        before => Service['controller']
    }

    vs_config { 'external_ids:ovn-remote':
        ensure  => present,
        value   => $ovn_remote,
        require => Service['openvswitch'],
    }

    vs_config { 'external_ids:ovn-encap-type':
        ensure  => present,
        value   => $ovn_encap_type,
        require => Service['openvswitch'],
    }

    vs_config { 'external_ids:ovn-encap-ip':
        ensure  => present,
        value   => $ovn_encap_ip,
        require => Service['openvswitch'],
    }
}
