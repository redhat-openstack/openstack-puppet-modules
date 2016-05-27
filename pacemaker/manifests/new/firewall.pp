# == Class: pacemaker::new::firewall
#
# Managaes the Corosync and Pacemaker firewall rules
#
# [*firewall_ipv6_manage*]
#   (boolean) Should the ipv6 rule be added?
#   Default: true
#
# [*firewall_corosync_manage*]
#   (boolean) Should the module manage Corosync firewall rules?
#   Default: true
#
# [*firewall_corosync_ensure*]
#   (present/absent) Should the rules be created or removed?
#   Default: present
#
# [*firewall_corosync_dport*]
#   The range of ports to open.
#   Default: ['5404', '5405']
#
# [*firewall_corosync_proto*]
#   Which protocol is being used?
#   Default: udp
#
# [*firewall_corosync_action*]
#   What should the rule do with the packets?
#   Default: accept
#
# [*firewall_pcsd_manage*]
#   (boolean) Should the module manage PCSD firewall rules?
#   Default: true
#
# [*firewall_pcsd_ensure*]
#   (present/absent) Should the rules be created or removed?
#   Default: present
#
# [*firewall_pcsd_dport*]
#   The range of ports to open.
#   Default: ['5404', '5405']
#
# [*firewall_pcsd_action*]
#   What should the rule do with the packets?
#   Default: accept
#
class pacemaker::new::firewall (
  $firewall_ipv6_manage     = $::pacemaker::new::params::firewall_ipv6_manage,
  
  $firewall_corosync_manage = $::pacemaker::new::params::firewall_corosync_manage,
  $firewall_corosync_ensure = $::pacemaker::new::params::firewall_corosync_ensure,
  $firewall_corosync_dport  = $::pacemaker::new::params::firewall_corosync_dport,
  $firewall_corosync_proto  = $::pacemaker::new::params::firewall_corosync_proto,
  $firewall_corosync_action = $::pacemaker::new::params::firewall_corosync_action,

  $firewall_pcsd_manage     = $::pacemaker::new::params::firewall_pcsd_manage,
  $firewall_pcsd_ensure     = $::pacemaker::new::params::firewall_pcsd_ensure,
  $firewall_pcsd_dport      = $::pacemaker::new::params::firewall_pcsd_dport,
  $firewall_pcsd_action     = $::pacemaker::new::params::firewall_pcsd_action,
) inherits ::pacemaker::new::params {
  validate_bool($firewall_ipv6_manage)

  validate_bool($firewall_corosync_manage)
  validate_string($firewall_corosync_ensure)
  validate_array($firewall_corosync_dport)
  validate_string($firewall_corosync_proto)
  validate_string($firewall_corosync_action)

  validate_bool($firewall_pcsd_manage)
  validate_string($firewall_pcsd_ensure)
  validate_array($firewall_pcsd_dport)
  validate_string($firewall_pcsd_action)

  if $firewall_corosync_manage {
    firewall { '001 corosync mcast' :
      ensure => $firewall_corosync_ensure,
      proto  => $firewall_corosync_proto,
      dport  => $firewall_corosync_dport,
      action => $firewall_corosync_action,
    }
    if $firewall_ipv6_manage {
      firewall { '001 corosync mcast ipv6' :
        ensure   => $firewall_corosync_ensure,
        proto    => $firewall_corosync_proto,
        dport    => $firewall_corosync_dport,
        action   => $firewall_corosync_action,
        provider => 'ip6tables',
      }
    }
  }

  if $firewall_pcsd_manage {
    firewall { '001 pcsd':
      ensure => $firewall_pcsd_ensure,
      proto  => 'tcp',
      dport  => $firewall_pcsd_dport,
      action => $firewall_pcsd_action,
    }
    if $firewall_ipv6_manage {
      firewall { '001 pcsd ipv6':
        ensure   => $firewall_pcsd_ensure,
        proto    => 'tcp',
        dport    => $firewall_pcsd_dport,
        action   => $firewall_pcsd_action,
        provider => 'ip6tables',
      }
    }
  }

}
