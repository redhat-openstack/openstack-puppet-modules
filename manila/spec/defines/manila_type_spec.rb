#Author: Andrew Woodward <awoodward@mirantis.com>

require 'spec_helper'

describe 'manila::type' do

  let(:title) {'hippo'}

  let :params do {
    :set_value      => ['name1','name2'],
    :set_key        => 'volume_backend_name',
    :os_password    => 'asdf',
    :os_tenant_name => 'admin',
    :os_username    => 'admin',
    :os_auth_url    => 'http://127.127.127.1:5000/v2.0/',
  }
  end

  it 'should have its execs' do
    should contain_exec('manila type-create hippo').with(
      :command => 'manila type-create hippo',
      :environment => [
        'OS_TENANT_NAME=admin',
        'OS_USERNAME=admin',
        'OS_PASSWORD=asdf',
        'OS_AUTH_URL=http://127.127.127.1:5000/v2.0/'],
      :unless  => 'manila type-list | grep hippo',
      :require => 'Package[python-manilaclient]')
    should contain_exec('manila type-key hippo set volume_backend_name=name1')
    should contain_exec('manila type-key hippo set volume_backend_name=name2')
  end
end
