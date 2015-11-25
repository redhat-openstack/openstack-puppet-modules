require 'spec_helper'

describe 'manila::keystone::auth' do

  let :params do
    {:password => 'pw'}
  end

  describe 'with only required params' do

    it 'should contain auth info' do

      is_expected.to contain_keystone_user('manila').with(
        :ensure   => 'present',
        :password => 'pw',
        :email    => 'manila@localhost',
      )
      is_expected.to contain_keystone_user_role('manila@services').with(
        :ensure  => 'present',
        :roles   => ['admin']
      )
      is_expected.to contain_keystone_service('manila').with(
        :ensure      => 'present',
        :type        => 'share',
        :description => 'Manila Service'
      )

    end
    it { is_expected.to contain_keystone_endpoint('RegionOne/manila').with(
      :ensure       => 'present',
      :public_url   => 'http://127.0.0.1:8786/v1/%(tenant_id)s',
      :admin_url    => 'http://127.0.0.1:8786/v1/%(tenant_id)s',
      :internal_url => 'http://127.0.0.1:8786/v1/%(tenant_id)s'
    ) }

  end

  context 'when overriding endpoint parameters' do
    before do
      params.merge!(
        :region            => 'RegionThree',
        :public_url   => 'https://10.0.42.1:4242/v42/%(tenant_id)s',
        :admin_url    => 'https://10.0.42.2:4242/v42/%(tenant_id)s',
        :internal_url => 'https://10.0.42.3:4242/v42/%(tenant_id)s'
      )
    end

    it { is_expected.to contain_keystone_endpoint('RegionThree/manila').with(
      :ensure       => 'present',
      :public_url   => 'https://10.0.42.1:4242/v42/%(tenant_id)s',
      :admin_url    => 'https://10.0.42.2:4242/v42/%(tenant_id)s',
      :internal_url => 'https://10.0.42.3:4242/v42/%(tenant_id)s'
    )}
  end

  context 'when deprecated endpoint parameters' do
    before do
       params.merge!(
        :public_address    => '10.0.42.1',
        :admin_address     => '10.0.42.2',
        :internal_address  => '10.0.42.3',
        :region            => 'RegionThree',
        :port              => '4242',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :public_protocol   => 'https',
        :share_version     => 'v42'
      )
     end

     it { is_expected.to contain_keystone_endpoint('RegionThree/manila').with(
      :ensure       => 'present',
      :public_url   => 'https://10.0.42.1:4242/v42/%(tenant_id)s',
      :admin_url    => 'https://10.0.42.2:4242/v42/%(tenant_id)s',
      :internal_url => 'https://10.0.42.3:4242/v42/%(tenant_id)s'
    )}
  end

  describe 'when endpoint should not be configured' do
    before do
      params.merge!(
        :configure_endpoint => false
      )
    end
    it { is_expected.to_not contain_keystone_endpoint('RegionOne/manila') }
  end
end
