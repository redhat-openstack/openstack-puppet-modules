# ## Class: pacemaker::new::setup::pcsd
# 
# A class to setup a pacemaker cluster using
# the "pcsd" service.
# 
# ### Parameters
# 
# [*cluster_nodes*]
#   (required) A list cluster nodes to be authenticated by the PCSD daemon and
#   be used in the cluster creation.
#   This data can be provided in several forms:
# 
#   * String: `'node1 node2 node3'`
#   * Array: `['node1', 'node2', 'node3']`
#   * Hash:
#     ```  
#     {
#       'node1' => {
#       'host' => 'my_node',
#     },
#       'node2' => {
#       'host' => 'other_node',
#       'ring0' => '192.168.0.1',
#     },
#       'node3' => {}
#     }
#     # Will be converted to:
#     ['my_node', '192.168.0.1', 'node3']
#     ```
# 
#   Elements in the hash are used in this priority:
#   1. *ring0, ring1, ...* have the highest priority.
#      They can be given either IP addresses or hostnames.
#   2. *ip* will be used if there is no *ring0*
#   2. *host* will be used if there is no *ip*
#   3. Hash keys will be used if there is no *host*
# 
# [*cluster_rrp_nodes*]
#   (optional) A list of nodes that will be actually used to create the cluster.
#   It will be equal to the *cluster_nodes* if not provided or can be set using
#   the same ways as the *cluster_nodes* does.
#   This can be used o either just override the list of cluster nodes and make
#   it different from nodes used for **pcsd** authentication, or to make a
#   Redundant Ring Protocol (RRP) enabled cluster.
# 
#   RRP nodes can be specified by providing all node's interfaces as a
#   comma-separated list. For example, *node1* has interface *node1a* in the
#   first ring and node1b in the second ring. Node2 has the same interfaces.
#   In this case, RRP nodes can be provided like this:
# 
#   * String: `'node1a,node1b node2a,node2b'`
#   * Array: `['node1a,node1b', 'node2a,node2b']`
#   * Hash:
#     ```
#     {
#     'node1' => {
#       'host' => 'my_node',
#       'ip' => '192.168.0.1',
#     },
#     'node2' => {
#       'host' => 'other_node',
#       'ring0' => '192.168.0.2',
#       'ring1' => '172.16.0.2',
#     },
#     'node3' => {}
#     }
#     # Will be converted to:
#     ['192.168.0.1', '192.168.0.2,172.16.0.2', 'node3']
#     ```
# 
# [*cluster_name*]
#   (optional) The name of the cluster (no whitespace)
#   Default: clustername
# 
# [*cluster_setup*]
#   (optional) If your cluster includes **pcsd**, this should be set to true for
#   just one node in cluster.  Else set to true for all nodes.
#   Default: true
# 
# [*cluster_options*]
#   (optional) Hash additional cluster configuration options.
#   Can be specified like this:
# 
#   * String: `'--token 10000 --ipv6 --join 100`
#   * Array: `['--token', '10000', '--ipv6', '', '--join', '100']`
#   * Hash:
#     ```
#     {
#       '--token' => '10000',
#       '--ipv6'  => '',
#       '--join'  => '100',
#     }
#     # Or:
#     {
#       'token' => '10000',
#       'ipv6'  => '',
#       'join'  => '100',
#     }
#     ```
#
# Supported cluster options:
# * transport udpu|udp
# * rrpmode active|passive
# * addr0 <addr/net>
# * mcast0 <address>
# * mcastport0 <port>
# * ttl0 <ttl>
# * broadcast0
# * addr1 <addr/net>
# * mcast1 <address>
# * mcastport1 <port>
# * ttl1 <ttl>
# * broadcast1
# * wait_for_all=<0|1>
# * auto_tie_breaker=<0|1>
# * last_man_standing=<0|1>
# * last_man_standing_window=<time in ms>
# * ipv6
# * token <timeout>
# * token_coefficient <timeout>
# * join <timeout>
# * consensus <timeout>
# * miss_count_const <count>
# * fail_recv_const <failures>
# 
# [*cluster_user*]
#   The user used by PCSD to authenticate nodes
# 
# [*cluster_group*]
#   The group of the user used by PCSD to authenticate nodes
# 
# [*cluster_password*]
#   Plaintext password of the user used by PCSD to authenticate nodes
# 
# [*pcs_bin_path*]
#   Path to the 'pcs' command
#
class pacemaker::new::setup::pcsd (
  $cluster_nodes     = $::pacemaker::new::params::cluster_nodes,
  $cluster_rrp_nodes = $::pacemaker::new::params::cluster_rrp_nodes,
  $cluster_name      = $::pacemaker::new::params::cluster_name,
  $cluster_setup     = $::pacemaker::new::params::cluster_setup,
  $cluster_options   = $::pacemaker::new::params::cluster_options,
  $cluster_user      = $::pacemaker::new::params::cluster_user,
  $cluster_group     = $::pacemaker::new::params::cluster_group,
  $cluster_password  = $::pacemaker::new::params::cluster_password,
  $pcs_bin_path      = $::pacemaker::new::params::pcs_bin_path,
) inherits ::pacemaker::new::params {
  validate_string($cluster_name)
  validate_bool($cluster_setup)
  validate_string($cluster_user)
  validate_string($cluster_group)
  validate_string($cluster_password)
  validate_absolute_path($pcs_bin_path)

  $cluster_nodes_array = pacemaker_cluster_nodes($cluster_nodes, 'array')
  $cluster_setup_nodes = pick($cluster_rrp_nodes, $cluster_nodes, [])
  $cluster_setup_nodes_list = pacemaker_cluster_nodes($cluster_setup_nodes, 'list')

  user { 'hacluster' :
    name     => $cluster_user,
    password => pw_hash($cluster_password, 'SHA-512', fqdn_rand_string(10)),
    groups   => $cluster_group,
  }

  pacemaker_pcsd_auth { 'setup' :
    success  => true,
    nodes    => $cluster_nodes_array,
    username => $cluster_user,
    password => $cluster_password,
    whole    => true,
    local    => false,
    force    => false,
  }

  if $cluster_setup {
    $cluster_options_list = pacemaker_cluster_options($cluster_options)

    exec { 'create-cluster' :
      creates => '/etc/cluster/cluster.conf',
      command => "${pcs_bin_path} cluster setup --name ${cluster_name} ${cluster_setup_nodes_list} ${cluster_options_list}",
      unless  => '/usr/bin/test -f /etc/corosync/corosync.conf',
      tag     => 'pacemaker-setup',
    }

    exec { 'start-cluster' :
      unless  => "${pcs_bin_path} status >/dev/null 2>&1",
      command => "${pcs_bin_path} cluster start --all",
      tag     => 'pacemaker-setup',
    }

    # the cluster should first be created and then started
    Exec['create-cluster'] ->
    Exec['start-cluster']
  }

  pacemaker_online { 'setup' :}

  # hacluster user is required to run auth
  # and should notify it to reauth if its password changes
  User['hacluster'] ~>
  Pacemaker_pcsd_auth['setup']

  # online check should always be after the auth commands
  Pacemaker_pcsd_auth['setup'] ->
  Pacemaker_online['setup']

  # always run auth before setup commands
  Pacemaker_pcsd_auth['setup'] ->
  Exec <|tag == 'pacemaker-setup'|> ->
  Pacemaker_online['setup']

  # run the cluster services after they have
  # already been setup and enabled by the pcsd
  # it should be an idempotent action
  # all cluster services should go before online check
  Exec <| tag == 'pacemaker-setup' |> ->
  Service <| tag == 'cluster-service' |> ->
  Pacemaker_online['setup']
}
