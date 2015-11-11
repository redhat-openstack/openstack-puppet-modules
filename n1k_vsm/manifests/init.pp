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
# [*pacemaker_control*]
#  (optional) Set to determine if pacemaker will control the VSM. If true will deploy both
#  primary and secondary VSMs on all nodes and will not start VSM. Defaults to false and
#  thus is optional unless this functionality is being used.
#
# [*existing_bridge*]
#  (required) If VSM should be installed behind an existing bridge, this should be set to
#  true and the bridge name should be provided in phy_if_bridge.
#
# [*vsm_mac_base*]
#  (optional) If set, provides randomization for the MAC addresses for the VSM VM(s).
#  Should be a (random) hexadecimal number of at least 7 digits (more is fine).
#
# [*phy_bridge_vlan*]
#  (optional) In the case that the management interface is a bridge with a tagged
#  uplink port, the VLAN tag for that uplink port can be provided which will
#  be applied on the patch port connecting vsm-br and the management bridge.
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
    $pacemaker_control = false,
    $existing_bridge   = false,
    $vsm_mac_base      = '',
    $phy_bridge_vlan   = 0,
) {

    if($::osfamily != 'Redhat') {
      #current support exists for Redhat family.
      #Support for Debian will be added soon.
      fail("Unsupported osfamily ${::osfamily}")
    }

    # Ensure role is set to primary for pacemaker controlled deployment
    # Additionally setup the extra variables for the secondary VSM
    if ($n1k_vsm::pacemaker_control) {
      $vsm_role_s = 'secondary'
      $vsmname_s  = 'vsm-s'
      $imgfile_s  = "/var/spool/cisco/vsm/${vsm_role_s}_repacked.iso"
      $diskfile_s = "/var/spool/cisco/vsm/${vsm_role_s}_disk"
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

    #Set bridge name properly
    $ovsbridge        = 'vsm-br'

    #VSM installation will be done only once. Will not respond to puppet sync
    $_check_phy_if_bridge = regsubst($n1k_vsm::phy_if_bridge, '[.:-]+', '_', 'G')
    $_phy_mac_addr        = inline_template("<%= scope.lookupvar('::macaddress_${_check_phy_if_bridge}') %>")
    if $_phy_mac_addr != '' {
        include ::n1k_vsm::pkgprep_ovscfg
    }

    notify {"Arg: intf ${phy_if_bridge} vsm_role ${vsm_role} domainid ${vsm_domain_id}" : withpath => true}
    notify {"ovs ${ovsbridge} vsmname ${n1k_vsm::vsmname}" : withpath => true}
    notify {"mgmtip ${n1k_vsm::mgmtip} vsm_mask ${n1k_vsm::mgmtnetmask} vsm_gw ${n1k_vsm::mgmtgateway}": withpath => false}

    include ::n1k_vsm::vsmprep
    include ::n1k_vsm::deploy
    Class['n1k_vsm::vsmprep'] -> Class['n1k_vsm::deploy']
}
