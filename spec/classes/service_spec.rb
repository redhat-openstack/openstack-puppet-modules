require 'spec_helper'

describe 'zookeeper::service' do
  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
  }}

  it { should contain_package('zookeeperd') }
  it { should contain_service('zookeeper').with(
    :ensure => 'running',
    :enable => true
  )}
end
