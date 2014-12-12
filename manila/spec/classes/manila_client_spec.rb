require 'spec_helper'

describe 'manila::client' do
  it { should contain_package('python-manilaclient').with_ensure('present') }
  let :facts do
    {:osfamily => 'Debian'}
  end
  context 'with params' do
    let :params do
      {:package_ensure => 'latest'}
    end
    it { should contain_package('python-manilaclient').with_ensure('latest') }
  end
end
