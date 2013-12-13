require 'spec_helper'

describe 'zookeeper::install' do
  shared_examples 'debian-install' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}

    it { should contain_package('zookeeper') }
    it { should contain_package('zookeeperd') }
    it { should contain_package('cron') }
  end

  context 'on debian-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :snap_retain_count => 1,
    } }

    it_behaves_like 'debian-install', 'Debian', 'squeeze'
    it_behaves_like 'debian-install', 'Debian', 'wheezy'
    it_behaves_like 'debian-install', 'Ubuntu', 'precise'
  end

  context 'without cron' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    let(:params) { {
      :snap_retain_count => 0,
    } }

    it { should contain_package('zookeeper') }
    it { should contain_package('zookeeperd') }
    it { should_not contain_package('cron') }
  end

end
