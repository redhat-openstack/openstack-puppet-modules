require 'spec_helper'

describe 'manila::db::sync' do

  let :facts do
    {:osfamily => 'Debian'}
  end
  it { should contain_exec('manila-manage db_sync').with(
    :command     => 'manila-manage db sync',
    :path        => '/usr/bin',
    :user        => 'manila',
    :refreshonly => true,
    :logoutput   => 'on_failure'
  ) }

end
