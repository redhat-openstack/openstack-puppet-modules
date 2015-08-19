require 'spec_helper'
describe 'cassandra::opscenter::cluster_name' do
  let(:pre_condition) { [
    'define ini_setting($ensure = nil,
       $path,
       $section,
       $key_val_separator       = nil,
       $setting,
       $value                   = nil) {}'
  ] }

  context 'Test that settings can be set.' do
    let(:title) { 'section setting' }
    let :params do
      {
        :cassandra_seed_hosts       => 'host1,host2',
      }
    end

    it {
      should contain_file('/etc/opscenter/clusters').with({
        'ensure' => 'directory',
      })
    }

    it {
      should contain_ini_setting('cassandra_seed_hosts').with({
        'ensure'  => 'present',
        'section' => 'cassandra',
        'setting' => 'seed_hosts',
        'value'   => 'host1,host2',
      })
    }
  end
end
