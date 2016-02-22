require 'spec_helper'
describe 'zaqar::server' do

  let :facts do
    { :osfamily => 'RedHat' }
  end

  describe 'with a zaqar server enabled' do
    let :pre_condition do
      "class {'::zaqar': admin_password => 'foo'}"
    end

    it { is_expected.to contain_service('openstack-zaqar').with(
        :ensure => 'running',
        :enable => true
    )}

  end

end
