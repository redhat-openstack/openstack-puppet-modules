require 'spec_helper'
describe 'cassandra::java' do

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it {
      should contain_class('cassandra::java')
      should contain_package('java-1.7.0-openjdk-headless')
    }
  end

  context 'On an Ubuntu OS with defaults for all parameters' do
    let :facts do
      {
        :operatingsystem => 'Ubuntu'
      }
    end

    it {
      should contain_class('cassandra::java')
      should contain_package('openjdk-7-jre-headless')
    }
  end

  context 'With java_package_name set to foobar' do
    let :params do
      {
        :package_name   => 'foobar-java',
        :ensure         => '42',
      }
    end

    it {
      should contain_package('foobar-java').with({
        :ensure => 42,
      })
    }
  end

  context 'On an unknown OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end

    it {
      expect {
        should raise_error(Puppet::Error)
      }
    }
  end
end
