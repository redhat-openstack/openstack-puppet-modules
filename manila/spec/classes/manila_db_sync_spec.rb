require 'spec_helper'

describe 'manila::db::sync' do

  let :facts do
    @default_facts.merge({:osfamily => 'Debian'})
  end
  it { is_expected.to contain_exec('manila-manage db_sync').with(
    :command     => 'manila-manage db sync',
    :path        => '/usr/bin',
    :user        => 'manila',
    :refreshonly => true,
    :logoutput   => 'on_failure'
  ) }

end
