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
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/#auto_bootstrap: true/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/batchlog_replay_throttle_in_kb: 1024/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/cas_contention_timeout_in_ms: 1000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/column_index_size_in_kb: 64/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/commit_failure_policy: stop/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/compaction_throughput_mb_per_sec: 16/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/counter_cache_save_period: 7200/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/counter_write_request_timeout_in_ms: 5000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/cross_node_timeout: false/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/dynamic_snitch_badness_threshold: 0.1/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/dynamic_snitch_reset_interval_in_ms: 600000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/dynamic_snitch_update_interval_in_ms: 100/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/hinted_handoff_throttle_in_kb: 1024/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/index_summary_resize_interval_in_minutes: 60/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/inter_dc_tcp_nodelay: false/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/max_hints_delivery_threads: 2/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/max_hint_window_in_ms: 10800000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/permissions_validity_in_ms: 2000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/range_request_timeout_in_ms: 10000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/read_request_timeout_in_ms: 5000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/request_scheduler: org.apache.cassandra.scheduler.NoScheduler/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/request_timeout_in_ms: 10000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/row_cache_save_period: 0/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/row_cache_size_in_mb: 0/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/sstable_preemptive_open_interval_in_mb: 50/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/tombstone_failure_threshold: 100000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/tombstone_warn_threshold: 1000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/trickle_fsync: false/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/trickle_fsync_interval_in_kb: 10240/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/truncate_request_timeout_in_ms: 60000/)
    }
    it {
      should contain_file('/etc/cassandra/cassandra.yaml').with_content(/write_request_timeout_in_ms: 2000/)
    }
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

  context 'CASSANDRA-9822 not activated on Debian (default)' do
    let :facts do
      {
        :osfamily => 'Debian',
        :lsbdistid => 'Ubuntu',
        :lsbdistrelease => '14.04'
      }
    end
    it { is_expected.not_to contain_file('/etc/init.d/cassandra') }
  end

  context 'CASSANDRA-9822 activated on Debian' do
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
end
