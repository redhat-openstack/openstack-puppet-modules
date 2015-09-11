require 'spec_helper'
describe 'cassandra' do
  let(:pre_condition) { [
    'class apt () {}',
    'class apt::update () {}',
    'define apt::key ($id, $source) {}',
    'define apt::source ($location, $comment, $release, $include) {}',
    'define ini_setting($ensure = nil,
       $path,
       $section,
       $key_val_separator       = nil,
       $setting,
       $value                   = nil) {}',
  ] }

  context 'On an unknown OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end
    let :params do
      {
        :fail_on_non_suppoted_os => true
      }
    end

    it {
      expect {
        should raise_error(Puppet::Error)
      }
    }
  end

  context 'On an unsupported OS pleading tolerance' do
    let :facts do
      {
        :osfamily => 'Darwin'
      }
    end
    let :params do
      {
        :fail_on_non_suppoted_os => false
      }
    end

    it {
      should compile
    }
  end

  context 'Test the dc and rack properties.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :snitch_properties_file => 'cassandra-topology.properties',
        :dc                     => 'NYC',
        :rack                   => 'R101',
        :dc_suffix              => '_1_cassandra',
        :prefer_local           => 'true'
      }
    end
    it {
      should contain_ini_setting('rackdc.properties.dc').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'dc',
        'value'   => 'NYC'
      })
    }
    it {
      should contain_ini_setting('rackdc.properties.rack').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'rack',
        'value'   => 'R101'
      })
    }
    it {
      should contain_ini_setting('rackdc.properties.dc_suffix').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'dc_suffix',
        'value'   => '_1_cassandra'
      })
    }
    it {
      should contain_ini_setting('rackdc.properties.prefer_local').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-topology.properties',
        'section' => '',
        'setting' => 'prefer_local',
        'value'   => 'true'
      })
    }
  end

  context 'Ensure cassandra service can be stopped and disabled.' do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    let :params do
      {
        :service_ensure => 'stopped',
        :service_enable => 'false'
      }
    end
    it {
      should contain_service('cassandra').with({
        'ensure' => 'stopped',
        'enable' => 'false'
      })
    }
  end
end
