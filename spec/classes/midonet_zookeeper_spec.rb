require 'spec_helper'

describe 'midonet::zookeeper' do

  shared_examples_for 'cluster zookeeper' do
    let :params do
    {
      :servers   =>  [{"id" => 1, "host" => 'node_1'},
                      {"id" => 3, "host" => 'node_2'},
                      {"id" => 2, "host" => 'node_3'}],
      :server_id => 3
    }
    end

    let :zookeeper_params do
    {
      # Please note the output is sorted by input 'ids'
      :servers => ['node_1', 'node_3', 'node_2'],
      :id      => 3
    }
    end

    it 'should call deric/zookeeper properly' do
      is_expected.to contain_class('zookeeper').with({
         'servers'   => zookeeper_params[:servers],
         'id'        => zookeeper_params[:id],
         'client_ip' => '127.0.0.1'
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
        :ipaddress       => '127.0.0.1',
        :hostname        => 'test.puppet'
      }
    end
    it_configures 'cluster zookeeper'
  end

  context 'on RedHat' do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 7,
        :ipaddress                 => '127.0.0.1',
        :hostname                  => 'test.puppet'
      }
    end
    it_configures 'cluster zookeeper'
  end

end
