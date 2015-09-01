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
    it {
      should contain_service('cassandra').with({
        'ensure' => 'running',
        'enable' => 'true'
      })
    }
    it { should contain_file('/etc/cassandra/cassandra.yaml') }
    it { should contain_package('dsc22') }
    it { is_expected.to contain_service('cassandra') }
    it { is_expected.not_to contain_class('apt') }
    it { is_expected.not_to contain_class('apt::update') }
    it { is_expected.not_to contain_apt__key('datastaxkey') }
    it { is_expected.not_to contain_apt__source('datastax') }
    it { is_expected.not_to contain_exec('update-cassandra-repos') }
    it {
      should contain_ini_setting('rackdc.properties.dc').with({
        'path'    => '/etc/cassandra/cassandra-rackdc.properties',
        'section' => '',
        'setting' => 'dc',
        'value'   => 'DC1'
      })
    }
    it {
      should contain_ini_setting('rackdc.properties.rack').with({
        'path'    => '/etc/cassandra/cassandra-rackdc.properties',
        'section' => '',
        'setting' => 'rack',
        'value'   => 'RAC1'
      })
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
        :manage_dsc_repo => true,
        :service_name    => 'foobar_service'
      }
    end

    it { should contain_class('apt') }
    it { should contain_class('apt::update') }

    it {
      is_expected.to contain_apt__key('datastaxkey').with({
        'id'     => '7E41C00F85BFC1706C4FFFB3350200F2B999A372',
        'source' => 'http://debian.datastax.com/debian/repo_key',
      })
    }

    it {
      is_expected.to contain_apt__source('datastax').with({
        'location' => 'http://debian.datastax.com/community',
        'comment'  => 'DataStax Repo for Apache Cassandra',
        'release'  => 'stable',
      })
    }

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
      is_expected.to contain_file('/etc/dse/cassandra/cassandra.yaml')
      is_expected.to contain_package('dse-full').with_ensure('4.7.0-1')
      is_expected.to contain_service('cassandra').with_name('dse')
    }
  end

  context 'CASSANDRA-9822 not activated on Ubuntu (default)' do
    let :facts do
      {
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistrelease => '14.04'
      }
    end
    it { is_expected.not_to contain_file('/etc/init.d/cassandra') }
  end

  context 'CASSANDRA-9822 activated on Ubuntu' do
    let :facts do
      {
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistrelease => '14.04'
      }
    end

    let :params do
      {
        :cassandra_9822 => true
      }
    end

    it { is_expected.to contain_file('/etc/init.d/cassandra') }
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

  context 'Test the cassandra.yml temlate.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :authenticator                         => 'foo',
        :authorizer                            => 'foo',
        :auto_snapshot                         => 'foo',
        :client_encryption_enabled             => 'foo',
        :client_encryption_keystore            => 'foo',
        :client_encryption_keystore_password   => 'foo',
        :cluster_name                          => 'foo',
        :commitlog_directory                   => 'foo',
        :concurrent_counter_writes             => 'foo',
        :concurrent_reads                      => 'foo',
        :concurrent_writes                     => 'foo',
        :config_path                           => '/etc',
        :data_file_directories                 => ['foo', 'bar'],
        :disk_failure_policy                   => 'foo',
        :endpoint_snitch                       => 'foo',
        :hinted_handoff_enabled                => 'foo',
        :incremental_backups                   => 'foo',
        :internode_compression                 => 'foo',
        :listen_address                        => 'foo',
        :native_transport_port                 => 'foo',
        :num_tokens                            => 'foo',
        :partitioner                           => 'foo',
        :rpc_address                           => 'foo',
        :rpc_port                              => 'foo',
        :rpc_server_type                       => 'foo',
        :saved_caches_directory                => 'foo',
        :seeds                                 => 'foo',
        :server_encryption_internode           => 'foo',
        :server_encryption_keystore            => 'foo',
        :server_encryption_keystore_password   => 'foo',
        :server_encryption_truststore          => 'foo',
        :server_encryption_truststore_password => 'foo',
        :snapshot_before_compaction            => 'foo',
        :ssl_storage_port                      => 'foo',
        :start_native_transport                => 'foo',
        :start_rpc                             => 'foo',
        :storage_port                          => 'foo',
      }
    end

    it { should contain_file('/etc/cassandra.yaml').with_content(/authenticator: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/authorizer: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/auto_snapshot: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/enabled: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/cluster_name: 'foo'/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/commitlog_directory: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/concurrent_counter_writes: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/concurrent_reads: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/concurrent_writes: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/^    - foo$/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/disk_failure_policy: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/endpoint_snitch: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/hinted_handoff_enabled: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/incremental_backups: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_compression: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/listen_address: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/native_transport_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/num_tokens: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/partitioner: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_address: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_server_type: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/saved_caches_directory: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/ - seeds: "foo"/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_encryption: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truststore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truststore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/snapshot_before_compaction: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/ssl_storage_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/start_native_transport: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/start_rpc: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/storage_port: foo/) }
  end

  context 'Test the cassandra1.yml temlate.' do
    let :facts do
      {
        :osfamily => 'RedHat'
      }
    end

    let :params do
      {
        :authenticator                         => 'foo',
        :authorizer                            => 'foo',
        :auto_snapshot                         => 'foo',
        :cassandra_yaml_tmpl                   => 'cassandra/cassandra1.yaml.erb',
        :client_encryption_enabled             => 'foo',
        :client_encryption_keystore            => 'foo',
        :client_encryption_keystore_password   => 'foo',
        :cluster_name                          => 'foo',
        :commitlog_directory                   => 'foo',
        :config_path                           => '/etc',
        :data_file_directories                 => ['foo', 'bar'],
        :disk_failure_policy                   => 'foo',
        :endpoint_snitch                       => 'foo',
        :hinted_handoff_enabled                => 'foo',
        :incremental_backups                   => 'foo',
        :internode_compression                 => 'foo',
        :listen_address                        => 'foo',
        :native_transport_port                 => 'foo',
        :num_tokens                            => 'foo',
        :partitioner                           => 'foo',
        :rpc_address                           => 'foo',
        :rpc_port                              => 'foo',
        :rpc_server_type                       => 'foo',
        :saved_caches_directory                => 'foo',
        :seeds                                 => 'foo',
        :server_encryption_internode           => 'foo',
        :server_encryption_keystore            => 'foo',
        :server_encryption_keystore_password   => 'foo',
        :server_encryption_truststore          => 'foo',
        :server_encryption_truststore_password => 'foo',
        :snapshot_before_compaction            => 'foo',
        :ssl_storage_port                      => 'foo',
        :start_native_transport                => 'foo',
        :start_rpc                             => 'foo',
        :storage_port                          => 'foo',
      }
    end

    it { should contain_file('/etc/cassandra.yaml').with_content(/authenticator: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/authorizer: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/auto_snapshot: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/enabled: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/cluster_name: 'foo'/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/commitlog_directory: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/^    - foo$/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/disk_failure_policy: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/endpoint_snitch: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/hinted_handoff_enabled: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/incremental_backups: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_compression: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/listen_address: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/native_transport_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/num_tokens: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/partitioner: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_address: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/rpc_server_type: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/saved_caches_directory: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/ - seeds: "foo"/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/internode_encryption: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/keystore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truststore: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/truststore_password: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/snapshot_before_compaction: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/ssl_storage_port: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/start_native_transport: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/start_rpc: foo/) }
    it { should contain_file('/etc/cassandra.yaml').with_content(/storage_port: foo/) }
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
