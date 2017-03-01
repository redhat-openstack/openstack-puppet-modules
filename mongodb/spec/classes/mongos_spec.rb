require 'spec_helper'

describe 'mongodb::mongos' do
  let :facts do
    {
      :osfamily        => 'Debian',
      :operatingsystem => 'Debian',
    }
  end

  let :params do
    {
      :configdb => ['127.0.0.1:27019']
    }
  end

  context 'with defaults' do
    it { should contain_class('mongodb::mongos::install') }
    it { should contain_class('mongodb::mongos::config') }
    it { should contain_class('mongodb::mongos::service') }
  end

  context 'when deploying on Solaris' do
    let :facts do
      { :osfamily        => 'Solaris' }
    end
    it { expect { should raise_error(Puppet::Error) } }
  end

end
