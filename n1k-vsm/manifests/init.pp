# == Class: n1k_vsm
#
# This class deploys a Nexus1000v VSM VEM in a server
#
# == Parameters:
#
# [*phy_if_bridge*]    - Physical interface used for the bridge to connect outside the node
#
# [*phy_gateway*]      - IP address of the default gateway for the external interface
#
# [*vsm_role*]         - Role (primary/secondary) of the Nexus1000v VSM
#
# [*vsm_domain_id*]    - Domain id of the Nexus1000v VSM
#
# [*vsm_admin_passwd*] - Password of admin user on the Nexus1000v VSM
#
# [*vsm_mgmt_ip*]      - IP of the management interface on the Nexus1000v VSM
#
# [*vsm_mgmt_netmask*] - IP netmask of the management interface of the Nexus1000v VSM
#
# [*vsm_mgmt_gateway*] - IP of the default gateway for the management interface of the Nexus1000v VSM
#
# [*n1kv_source*]      - Location where to get the Nexus1000v VSM ISO package
#
# [*n1kv_version*]     - Version of the Nexus1000v VSM
#
# == Actions:
#
# == Requires:
#
# == Sample Usage:
#
class n1k_vsm(
    $phy_if_bridge = 'enp1s0f0',
    $phy_gateway,
    $vsm_role = 'primary',
    $vsm_domain_id,
    $vsm_admin_passwd,
    $vsm_mgmt_ip,
    $vsm_mgmt_netmask,
    $vsm_mgmt_gateway,
    $n1kv_source = 'puppet:///modules/n1k_vsm/vsm.iso',
    $n1kv_version = 'latest'
) {
    #
    # Network parameters
    #
    $ovsbridge = 'br-int'
    $phy_ip_addr = inline_template("<%= scope.lookupvar('::ipaddress_${n1k_vsm::phy_if_bridge}') %>")
    $phy_ip_mask = inline_template("<%= scope.lookupvar('::netmask_${n1k_vsm::phy_if_bridge}') %>")
    #$gw_intf = inline_template("<%= scope.lookupvar('::gateway_device') %>")
    $gw_intf = $n1k_vsm::phy_gateway

    #
    # VSM parameters
    #
    if $n1k_vsm::vsm_role == 'primary' {
      $vsmname = 'vsm-p'
      $mgmtip = $vsm_mgmt_ip
      $mgmtnetmask = $vsm_mgmt_netmask
      $mgmtgateway = $vsm_mgmt_gateway
    } else { # secondary
      $vsmname = 'vsm-s'
      $mgmtip = '0.0.0.0'
      $mgmtnetmask = '0.0.0.0'
      $mgmtgateway = '0.0.0.0'
    }
    $consolepts = 2
    $memory = 4096000
    $vcpu = 2
    $disksize = 4
    $imgfile  = "/var/spool/vsm/${n1k_vsm::vsm_role}_repacked.iso"
    $diskfile = "/var/spool/vsm/${n1k_vsm::vsm_role}_disk"


    $Debug_Print = '/usr/bin/printf'
    $Debug_Log = '/tmp/n1kv_vsm_puppet.log'

    notify {"Arg: intf ${phy_if_bridge} vsm_role ${vsm_role} domainid ${vsm_domain_id}" : withpath => true}
    notify {"ip ${phy_ip_addr} mask ${phy_ip_mask} gw ${n1k_vsm::phy_gateway}" : withpath => true}
    notify {"gw_dv ${gw_intf} ovs ${ovsbridge} vsmname ${n1k_vsm::vsmname}" : withpath => true}
    notify {"mgmtip ${n1k_vsm::mgmtip} vsm_mask ${n1k_vsm::mgmtnetmask} vsm_gw ${n1k_vsm::mgmtgateway}": withpath => false}


    #
    # Clean up debug log
    #
    file {"File_${Debug_Log}":
      ensure => 'absent',
      path   => $Debug_Log,
#    } ->
#    file_line { "Adding info to debug":
#      path => $Debug_Log,
#      line => "phy ${n1k_vsm::phy_if_bridge} ip ${n1k_vsm::phy_ip_addr} gw ${n1k_vsm:phy_gateway}",
    }

    include n1k_vsm::pkgprep_ovscfg
    include n1k_vsm::vsmprep
    include n1k_vsm::deploy

    File["File_${Debug_Log}"] -> Class['n1k_vsm::pkgprep_ovscfg'] -> Class['n1k_vsm::vsmprep'] -> Class['n1k_vsm::deploy']
}
