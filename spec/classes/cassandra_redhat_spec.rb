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

  context 'On a RedHat OS with defaults for all parameters' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    it { should contain_class('cassandra') }
    it { should contain_file('/etc/cassandra/default.conf/cassandra.yaml') }
    it {
      should contain_service('cassandra').with({
        'ensure' => 'running',
        'enable' => 'true'
      })
    }
    it { should contain_package('dsc22') }
    it { is_expected.not_to contain_yumrepo('datastax') }
    it {
      should contain_ini_setting('rackdc.properties.dc').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-rackdc.properties',
        'section' => '',
        'setting' => 'dc',
        'value'   => 'DC1'
      })
    }
    it {
      should contain_ini_setting('rackdc.properties.rack').with({
        'path'    => '/etc/cassandra/default.conf/cassandra-rackdc.properties',
        'section' => '',
        'setting' => 'rack',
        'value'   => 'RAC1'
      })
    }
    it {
      should contain_file('/var/lib/cassandra/data').with({
        'ensure' => 'directory',
        'owner'  => 'cassandra',
        'group'  => 'cassandra',
        'mode'   => '0750'
      })
    }
    it {
      should contain_file('/var/lib/cassandra/commitlog').with({
        'ensure' => 'directory',
        'owner'  => 'cassandra',
        'group'  => 'cassandra',
        'mode'   => '0750'
      })
    }
    it {
      should contain_file('/var/lib/cassandra/saved_caches').with({
        'ensure' => 'directory',
        'owner'  => 'cassandra',
        'group'  => 'cassandra',
        'mode'   => '0750'
      })
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
        :manage_dsc_repo => true,
      }
    end

    it { should contain_yumrepo('datastax') }
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
      is_expected.to contain_file('/etc/dse/cassandra/cassandra.yaml')
      is_expected.to contain_package('dse-full').with_ensure('4.7.0-1')
      is_expected.to contain_service('cassandra').with_name('dse')
    }
  end

  context 'CASSANDRA-9822 activated on Red Hat' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :cassandra_9822 => true
      }
    end

    it { is_expected.not_to contain_file('/etc/init.d/cassandra') }
  end
end
