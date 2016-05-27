require 'spec_helper'

describe 'pacemaker::new::setup::config', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      if facts[:osfamily] == 'Debian'
        log_file_path = '/var/log/corosync/corosync.log'
      elsif facts[:osfamily] == 'RedHat'
        log_file_path = '/var/log/cluster/corosync.log'
      else
        log_file_path = ''
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::setup::config') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_pacemaker_online('setup') }

        config = <<-eof

totem {
    clear_node_high_bit: yes
    cluster_name:        clustername
    secauth:             off
    transport:           udpu
    version:             2
    vsftype:             none
}

logging {
    debug:           off
    function_name:   on
    logfile:         #{log_file_path}
    syslog_facility: daemon
    timestamp:       on
    to_logfile:      yes
    to_syslog:       yes
}

nodelist {
    node {
        nodeid:     1
        ring0_addr: localhost
    }
}

quorum {
    provider: corosync_votequorum
    two_node: 1
}


amf {
    mode: disabled
}

aisexec {
    user:  root
    group: root
}
        eof

        it { is_expected.to contain_file('corosync-config').with_content(config) }

      end

      context 'with custom parameters' do
        let(:params) do
          {
              :cluster_nodes => {
                  'node1' => {
                      'vote' => '2',
                      'ring0' => '192.168.0.1',
                      'ring1' => '172.16.0.1',
                  },
                  'node2' => {
                      'ring0' => '192.168.0.2',
                      'ring1' => '172.16.0.2',
                  },
                  'node3' => {
                      'ring0' => '192.168.0.3',
                      'ring1' => '172.16.0.3',
                  },
              },
              :cluster_options => {
                'compatibility' => 'corosync-1.0.0',
                'transport' => 'udp',
              },
              :cluster_auth_enabled => true,
              :cluster_name => 'my_cluster',
              :cluster_interfaces => [
                  {
                      'ringnumber' => '0',
                      'bindnetaddr' => '192.168.0.0',
                      'mcastaddr' => '239.255.1.1',
                      'mcastport' => '5405',
                  },
                  {
                      'ringnumber' => '1',
                      'bindnetaddr' => '172.16.0.0',
                      'mcastaddr' => '239.255.2.1',
                      'mcastport' => '5405',
                  },
              ]
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('pacemaker::new::setup::config') }

        it { is_expected.to contain_class('pacemaker::new::params') }

        it { is_expected.to contain_pacemaker_online('setup') }

        config = <<-eof
compatibility: corosync-1.0.0

totem {
    clear_node_high_bit: yes
    cluster_name:        my_cluster
    secauth:             on
    transport:           udp
    version:             2
    vsftype:             none
    interface {
        bindnetaddr: 192.168.0.0
        mcastaddr:   239.255.1.1
        mcastport:   5405
        ringnumber:  0
    }
    interface {
        bindnetaddr: 172.16.0.0
        mcastaddr:   239.255.2.1
        mcastport:   5405
        ringnumber:  1
    }
}

logging {
    debug:           off
    function_name:   on
    logfile:         #{log_file_path}
    syslog_facility: daemon
    timestamp:       on
    to_logfile:      yes
    to_syslog:       yes
}

nodelist {
    node {
        name:       node1
        nodeid:     1
        ring0_addr: 192.168.0.1
        ring1_addr: 172.16.0.1
    }
    node {
        name:       node2
        nodeid:     2
        ring0_addr: 192.168.0.2
        ring1_addr: 172.16.0.2
    }
    node {
        name:       node3
        nodeid:     3
        ring0_addr: 192.168.0.3
        ring1_addr: 172.16.0.3
    }
}

quorum {
    provider: corosync_votequorum
}


amf {
    mode: disabled
}

aisexec {
    user:  root
    group: root
}
        eof

        it { is_expected.to contain_file('corosync-config').with_content(config) }

      end

    end
  end
end