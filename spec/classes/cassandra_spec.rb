require 'spec_helper'
describe 'cassandra' do
  let(:pre_condition) { [
    'class apt () {}',
    'class apt::update () {}',
    'define apt::key ($id, $source) {}',
    'define apt::source ($location, $comment, $release, $include) {}',
  ] }

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it { should contain_class('cassandra') }
    it { should contain_file('/etc/cassandra/default.conf/cassandra.yaml') }
    it { should contain_service('cassandra') }
    it { is_expected.not_to contain_yumrepo('datastax') }
  end

  context 'On a RedHat OS with manage_dsc_repo set to true' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :manage_dsc_repo => true,
      }
    end

    it { should contain_yumrepo('datastax') }
  end

  context 'On a Debian OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    it { should contain_class('cassandra') }
    it { should contain_service('cassandra') }
    it { should contain_file('/etc/cassandra/cassandra.yaml') }
    it { is_expected.to contain_service('cassandra') }
    it { is_expected.not_to contain_class('apt') }
    it { is_expected.not_to contain_class('apt::update') }
    it { is_expected.not_to contain_apt__key('datastaxkey') }
    it { is_expected.not_to contain_apt__source('datastax') }
    it { is_expected.not_to contain_exec('update-cassandra-repos') }
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
        :manage_dsc_repo => true,
        :service_name    => 'foobar_service'
      }
    end

    it { should contain_class('apt') }
    it { should contain_class('apt::update') }
    it { is_expected.to contain_apt__key('datastaxkey') }
    it { is_expected.to contain_apt__source('datastax') }
    it { is_expected.to contain_exec('update-cassandra-repos') }
    it { is_expected.to contain_service('cassandra') }
  end

  context 'Install DSE on a Red Hat family OS.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :package_ensure => '4.7.0-1',
        :package_name   => 'dse-full',
        :cluster_name   => 'DSE Cluster',
        :config_path    => '/etc/dse/cassandra',
        :service_name   => 'dse'
      }
    end

    it {
      is_expected.to contain_file('/etc/dse/cassandra/cassandra.yml')
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
