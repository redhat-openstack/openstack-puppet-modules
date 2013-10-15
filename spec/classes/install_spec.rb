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
  end

  context 'on debian-like system' do
    let(:user) { 'zookeeper' }
    let(:group) { 'zookeeper' }

    it_behaves_like 'debian-install', 'Debian', 'squeeze'
    it_behaves_like 'debian-install', 'Debian', 'wheezy'
    it_behaves_like 'debian-install', 'Ubuntu', 'precise'
  end

end
