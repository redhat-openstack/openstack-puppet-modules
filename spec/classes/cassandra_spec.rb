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
      should contain_file('/etc/cassandra/default.conf/cassandra.yaml')
      should contain_service('cassandra')
      is_expected.not_to contain_yumrepo('datastax')
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
      should contain_service('cassandra')
      should contain_class('cassandra::install')
      should contain_class('cassandra::config')
      should contain_file('/etc/cassandra/cassandra.yaml')
      is_expected.not_to contain_class('apt')
      is_expected.not_to contain_class('apt::update')
      is_expected.not_to contain_apt__key('datastaxkey')
      is_expected.not_to contain_apt__source('datastax')
      is_expected.not_to contain_exec('update-cassandra-repos')
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
      should contain_class('apt::update')
      is_expected.to contain_apt__key('datastaxkey')
      is_expected.to contain_apt__source('datastax')
      is_expected.to contain_exec('update-cassandra-repos')
    }
  end

  context 'With datastax_agent_package_ensure set to present' do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    let :params do
      {
        :datastax_agent_package_ensure => 'present',
        :datastax_agent_package_name   => 'datastax-agent-foo',
        :datastax_agent_service_name   => 'datastax-agent-bar'
      }
    end

    it {
      should contain_package('datastax-agent-foo')
      should contain_service('datastax-agent-bar')
    }
  end

  context 'With datastax_agent_package_ensure set to present' do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    let :params do
      {
        :datastax_agent_package_ensure => 'present',
        :datastax_agent_package_name   => 'da-foobar',
      }
    end

    it {
      should contain_package('da-foobar')
    }
  end

  context 'With cassandra_opt_package_ensure set to present' do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    let :params do
      {
        :cassandra_opt_package_ensure => 'present',
        :cassandra_opt_package_name   => 'opt-foobar',
      }
    end

    it {
      should contain_package('opt-foobar')
    }
  end

  context 'With java_package_name set to foobar' do
    let :facts do
      {
        :osfamily => 'RedHat',
      }
    end

    let :params do
      {
        :java_package_name   => 'foobar-java',
        :java_package_ensure => '42',
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
