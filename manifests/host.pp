# zookeeper host

define zookeeper::host($id, $client_ip, $election_port, $leader_port, $hostname = $title) {
  datacat_fragment { $hostname:
        target => '/etc/zookeeper/conf/quorum.conf',
        data   => {
            'id'            => $id,
            'client_ip'     => $client_ip,
            'election_port' => $election_port,
            'leader_port'   => $leader_port,
        },
  }
}