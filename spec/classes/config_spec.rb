require 'spec_helper'

describe 'zookeeper::config' do
  shared_examples 'debian-install' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
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

  end

  context 'on debian-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }
    let(:cfg_dir) { '/etc/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper' }


    it_behaves_like 'debian-install', 'Debian', 'wheezy'
  end

end
