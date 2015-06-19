require 'spec_helper'
describe 'cassandra' do

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it {
      should contain_class('cassandra')
      should contain_class('cassandra::install')
      should contain_class('cassandra::config')
    }
  end

  context 'On a RedHat OS with manage_dsc_repo set to true' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :manage_dsc_repo => true
      }
    end

    it {
      should contain_yumrepo('datastax')
    }
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it {
      should contain_class('cassandra')
      should contain_class('cassandra::install')
      should contain_class('cassandra::config')
    }
  end

  context 'On a Debian OS with manage_dsc_repo set to true' do
    let :facts do
      {
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistrelease => '14.04'
      }
    end

    let :params do
      {
        :manage_dsc_repo => true
      }
    end

    it {
      should contain_class('apt')
    }
  end

  context 'On a Supported OS with datastax_agent_ensure set to present' do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    let :params do
      {
        :datastax_agent_ensure => 'present'
      }
    end

    it {
      should contain_package('datastax-agent')
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
