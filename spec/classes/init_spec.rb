require 'spec_helper'

describe 'zookeeper', :type => :class do

  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
  }}

  it { should contain_class('zookeeper::config') }
  it { should contain_class('zookeeper::install') }
  it { should contain_class('zookeeper::service') }
  it { should compile.with_all_deps }


  context 'allow installing multiple packages' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :packages => [ 'zookeeper', 'zookeeper-bin' ],
    } }

    it { should contain_package('zookeeper').with({:ensure => 'present'}) }
    it { should contain_package('zookeeper-bin').with({:ensure => 'present'}) }
    it { should contain_service('zookeeper').with({:ensure => 'running'}) }
    # datastore exec is not included by default
    it { should_not contain_exec('initialize_datastore') }
  end

  context 'Cloudera packaging' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :packages             => ['zookeeper','zookeeper-server'],
      :service_name         => 'zookeeper-server',
      :initialize_datastore => true
    } }

    it { should contain_package('zookeeper').with({:ensure => 'present'}) }
    it { should contain_package('zookeeper-server').with({:ensure => 'present'}) }
    it { should contain_service('zookeeper-server').with({:ensure => 'running'})  }
    it { should contain_exec('initialize_datastore') }
  end


end