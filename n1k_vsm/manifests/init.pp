# == Class: n1k_vsm
#
# Deploy N1KV VSM as a VM on RHEL7 server.
# Support exists and tested for RedHat.
# (For Ubuntu/Debian platforms few changes and testing pending.)
#
# == Parameters:
#
# [*phy_if_bridge*]
#  (required) Physical interface that will be moved to the bridge for mgmt trafic
#
# [*phy_gateway*]
#  (required) Default gateway for the mgmt network
#
# [*vsm_role*]
#  (required) Role (standalone/primary/secondary) of the Nexus1000v VSM
#
# [*vsm_domain_id*]
#  (required) Domain id of the Nexus1000v VSM
#
# [*vsm_admin_passwd*]
#  (required) Password of admin user on the Nexus1000v VSM
#
# [*vsm_mgmt_ip*]
#  (required) IP of the management interface on the Nexus1000v VSM
#
# [*vsm_mgmt_netmask*]
#  (required) IP netmask of the management interface of the Nexus1000v VSM
#
# [*vsm_mgmt_gateway*]
#  (required) IP of the default gateway for the management interface of the Nexus1000v VSM
#
# [*n1kv_source*]
#  (required) Location where to get the Nexus1000v VSM ISO/RPM package
#
# [*n1kv_version*]
#  (required) Version of the Nexus1000v VSM
#
class n1k_vsm(
    $n1kv_source       = '',
    $n1kv_version      = 'latest',
    $phy_if_bridge     = 'enp1s0f0',
    $phy_gateway,
    $vsm_role          = 'primary',
    $vsm_domain_id,
    $vsm_admin_passwd,
    $vsm_mgmt_ip,
    $vsm_mgmt_netmask,
    $vsm_mgmt_gateway,
) {

    if($::osfamily != 'Redhat') {
      #current support exists for Redhat family.
      #Support for Debian will be added soon.
      fail("Unsupported osfamily ${::osfamily}")
    }

    if ($n1k_vsm::vsm_role == 'primary') or ($n1k_vsm::vsm_role == 'standalone') {
      $vsmname          = 'vsm-p'
      $mgmtip           = $vsm_mgmt_ip
      $mgmtnetmask      = $vsm_mgmt_netmask
      $mgmtgateway      = $vsm_mgmt_gateway
    } else { # secondary
      $vsmname          = 'vsm-s'
      $mgmtip           = '0.0.0.0'
      $mgmtnetmask      = '0.0.0.0'
      $mgmtgateway      = '0.0.0.0'
    }

    $consolepts         = 2
    $memory             = 4096000
    $vcpu               = 2
    $disksize           = 4
    $imgfile            = "/var/spool/cisco/vsm/${n1k_vsm::vsm_role}_repacked.iso"
    $diskfile           = "/var/spool/cisco/vsm/${n1k_vsm::vsm_role}_disk"
    $ovsbridge          = 'vsm-br'

    #VSM installation will be done only once. Will not respond to puppet sync
    $_phy_ip_addr       = inline_template("<%= scope.lookupvar('::ipaddress_${n1k_vsm::phy_if_bridge}') %>")
    if $_phy_ip_addr != '' {
      $phy_ip_addr      = inline_template("<%= scope.lookupvar('::ipaddress_${n1k_vsm::phy_if_bridge}') %>")
      $phy_ip_mask      = inline_template("<%= scope.lookupvar('::netmask_${n1k_vsm::phy_if_bridge}') %>")
      $gw_intf          = $n1k_vsm::phy_gateway
      include n1k_vsm::pkgprep_ovscfg
    }

    notify {"Arg: intf ${phy_if_bridge} vsm_role ${vsm_role} domainid ${vsm_domain_id}" : withpath => true}
    notify {"ip ${phy_ip_addr} mask ${phy_ip_mask} gw ${n1k_vsm::phy_gateway}" : withpath => true}
    notify {"gw_dv ${gw_intf} ovs ${ovsbridge} vsmname ${n1k_vsm::vsmname}" : withpath => true}
    notify {"mgmtip ${n1k_vsm::mgmtip} vsm_mask ${n1k_vsm::mgmtnetmask} vsm_gw ${n1k_vsm::mgmtgateway}": withpath => false}

    include n1k_vsm::vsmprep
    include n1k_vsm::deploy
    Class['n1k_vsm::vsmprep'] -> Class['n1k_vsm::deploy']
}
