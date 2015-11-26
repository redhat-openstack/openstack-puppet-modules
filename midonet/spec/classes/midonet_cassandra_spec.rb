require 'spec_helper'

describe 'midonet::cassandra' do

  let :params do
  {
    :seeds        => ['192.168.7.2', '192.168.7.3', '192.168.7.4'],
    :seed_address => '192.168.7.2'
  }
  end

  shared_examples_for 'cluster cassandra' do


    before do
      params.merge!(os_params)
    end

    it 'should call cassandra module properly' do
      is_expected.to contain_class('cassandra').with({
        'seeds'              => params[:seeds],
        'seed_address'       => params[:seed_address],
        'storage_port'       => '7000',
        'ssl_storage_port'   => '7001',
        'client_port'        => '9042',
        'client_port_thrift' => '9160'
      })
    end
  end

  context 'on Debian' do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistrelease  => '14.04',
        :lsbdistid       => 'Ubuntu',
        :lsbdistcodename => 'trusty',
        :ipaddress       => '127.0.0.1',
        :hostname        => 'test.puppet'
      }
    end

    let :os_params do
    {
      :pid_dir      => '/var/run/cassandra',
      :conf_dir     => '/etc/cassandra',
      :service_path => '/usr/sbin'
    }
    end

    it_configures 'cluster cassandra'
  end

  context 'on RedHat' do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystem           => 'CentOS',
        :operatingsystemmajrelease => 7,
        :ipaddress                 => '127.0.0.1',
        :hostname                  => 'test.puppet'
      }
    end

    let :os_params do
    {
      :pid_dir      => '/var/run/cassandra',
      :conf_dir     => '/etc/cassandra/default.conf',
      :service_path => '/sbin'
    }
    end

    it_configures 'cluster cassandra'
  end
end
