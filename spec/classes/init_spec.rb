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

    it { should contain_package('zookeeper') }
    it { should contain_package('zookeeper-bin') }
  end


end