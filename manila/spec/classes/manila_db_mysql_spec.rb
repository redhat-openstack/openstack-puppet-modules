require 'spec_helper'

describe 'manila::db::mysql' do

  let :req_params do
    {:password => 'pw',
    }
  end

  let :facts do
    {:osfamily => 'Debian'}
  end

  let :pre_condition do
    'include mysql::server'
  end

  describe 'with only required params' do
    let :params do
      req_params
    end
    it { is_expected.to contain_openstacklib__db__mysql('manila').with(
      :user         => 'manila',
      :password_hash => '*D821809F681A40A6E379B50D0463EFAE20BDD122',
      :host         => '127.0.0.1',
      :charset      => 'utf8'
     ) }
  end
  describe "overriding allowed_hosts param to array" do
    let :params do
      {
        :password       => 'manilapass',
        :allowed_hosts  => ['127.0.0.1','%']
      }
    end

  end
  describe "overriding allowed_hosts param to string" do
    let :params do
      {
        :password       => 'manilapass2',
        :allowed_hosts  => '192.168.1.1'
      }
    end

  end

  describe "overriding allowed_hosts param equals to host param " do
    let :params do
      {
        :password       => 'manilapass2',
        :allowed_hosts  => '127.0.0.1'
      }
    end

  end
end
