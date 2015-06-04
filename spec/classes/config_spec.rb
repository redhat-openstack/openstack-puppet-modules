require 'spec_helper'

describe 'zookeeper::config', :type => :class do

  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
    :ipaddress => '192.168.1.1',
  }}

  shared_examples 'common' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
      :ipaddress => '192.168.1.1',
    }}

    it { should contain_file(cfg_dir).with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { should contain_file(log_dir).with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { should contain_file(id_file).with({
      'ensure'  => 'file',
      'owner'   => user,
      'group'   => group,
    }).with_content(myid) }

    context 'extra parameters' do
      snap_cnt = 15000
      # set custom params
      let(:params) { {
        :log4j_prop    => 'ERROR',
        :snap_count    => snap_cnt,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/environment').with_content(/ERROR/)
      }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/snapCount=15000/)
      }
    end

    context 'max allowed connections' do
      max_conn = 15

      let(:params) {{
        :max_allowed_connections => max_conn
      }}

      it { should contain_file(
          '/etc/zookeeper/conf/zoo.cfg'
        ).with_content(/maxClientCnxns=#{max_conn}/) }
    end

    context 'set client ip address' do
      ipaddress = '192.168.1.1'
      let(:params){{
        :client_ip => ipaddress
      }}

      it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/clientPortAddress=#{ipaddress}/) }
    end


    context 'quorum file' do
      ipaddress = '192.168.1.1'
      let(:facts) {{
        :operatingsystem => os,
        :osfamily => 'Debian',
        :lsbdistcodename => codename,
        :ipaddress => ipaddress
      }}

      it { should create_datacat_fragment('192.168.1.1').with_data(
        {"id"=>myid, "client_ip"=>"192.168.1.1", "election_port"=>"2888", "leader_port"=>"3888"}
      )}
    end

    #  it { should contain_file(
    #    '/etc/zookeeper/conf/quorum.yml'
    #  )}
    #it { should contain_datacat__fragment("#{ipaddress}") }

    #  it { should contain_concat__fragment("zookeeper_#{ipaddress}") }

    context 'setting tick time' do
      tick_time = 3000
      let(:params) { {
        :tick_time => tick_time,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/tickTime=#{tick_time}/)
      }
    end

    context 'setting init and sync limit' do
      init_limit = 15
      sync_limit = 10
      let(:params) { {
        :init_limit => init_limit,
        :sync_limit => sync_limit,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/initLimit=#{init_limit}/)
      }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/syncLimit=#{sync_limit}/)
      }
    end

    context 'setting leader' do
      let(:params) { {
        :leader => false,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/leaderServes=no/)
      }
    end

    context 'set peer_type to observer' do
      let(:params){{
        :peer_type => 'observer'
      }}

      it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/peerType=observer/) }
    end

  end

  context 'on debian-like system' do
    let(:user)    { 'zookeeper' }
    let(:group)   { 'zookeeper' }
    let(:cfg_dir) { '/etc/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper' }
    let(:id_file) { '/etc/zookeeper/conf/myid' }
    let(:myid)    { /1/ }

    it_behaves_like 'common', 'Debian', 'wheezy'
  end

  context 'custom parameters' do
    # set custom params
    let(:params) { {
      :id      => '2',
      :user    => 'zoo',
      :group   => 'zoo',
      :cfg_dir => '/var/lib/zookeeper/conf',
      :log_dir => '/var/lib/zookeeper/log',
    } }

    let(:user)    { 'zoo' }
    let(:group)   { 'zoo' }
    let(:cfg_dir) { '/var/lib/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper/log' }
    let(:id_file) { '/var/lib/zookeeper/conf/myid' }
    let(:myid)    { /2/ }

    it_behaves_like 'common', 'Debian', 'wheezy'
  end

  context 'myid link' do
    it { should contain_file(
      '/var/lib/zookeeper/myid'
    ).with({
      'ensure' => 'link',
      'target' => '/etc/zookeeper/conf/myid',
    })}
  end

  context 'without datalogstore parameter' do
    it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/# dataLogDir=\/disk2\/zookeeper/)
    }
  end

  context 'with datalogstore parameter' do
    let(:params) {{
      :datalogstore => '/zookeeper/transaction/device',
    }}

    let(:datalogstore)  { '/zookeeper/transaction/device' }

    it { should contain_file(datalogstore).with({
      'ensure'  => 'directory',
    }) }

    it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/dataLogDir=\/zookeeper\/transaction\/device/)
    }
  end

  context 'setting quorum of servers with custom ports' do
    let(:params) {{
      :election_port => 3000,
      :leader_port   => 4000,
      :servers       => ['192.168.1.1', '192.168.1.2']
    }}

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.1=192.168.1.1:3000:4000/) }

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.2=192.168.1.2:3000:4000/) }
  end

  context 'setting quorum of servers with default ports' do
    let(:params) {{
      :servers => ['192.168.1.1', '192.168.1.2']
    }}

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.1=192.168.1.1:2888:3888/) }

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.2=192.168.1.2:2888:3888/) }
  end

  context 'setting quorum of servers with default ports with observer' do
    let(:params) {{
      :servers => ['192.168.1.1', '192.168.1.2', '192.168.1.3', '192.168.1.4', '192.168.1.5'],
      :observers => ['192.168.1.4', '192.168.1.5']
    }}

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.1=192.168.1.1:2888:3888/) }

    it { should_not contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.1=192.168.1.1:2888:3888:observer/) }

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.2=192.168.1.2:2888:3888/) }

    it { should_not contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.2=192.168.1.2:2888:3888:observer/) }

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.3=192.168.1.3:2888:3888/) }

    it { should_not contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.3=192.168.1.3:2888:3888:observer/) }

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.4=192.168.1.4:2888:3888:observer/) }

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/server.5=192.168.1.5:2888:3888:observer/) }
  end

  context 'setting minSessionTimeout' do
    let(:params) {{
      :min_session_timeout => 5000
    }}

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/minSessionTimeout=5000/) }
  end

  context 'setting maxSessionTimeout' do
    let(:params) {{
      :max_session_timeout => 50000
    }}

    it { should contain_file(
      '/etc/zookeeper/conf/zoo.cfg'
    ).with_content(/maxSessionTimeout=50000/) }
  end

end
