require 'spec_helper'

describe 'mistral::db::mysql' do

  let :pre_condition do
    [
      'include mysql::server',
      'include mistral::db::sync'
    ]
  end

  let :facts do
    { :osfamily => 'Debian' }
  end

  let :params do
    {
      'password'      => 'fooboozoo_default_password',
    }
  end

  describe 'with only required params' do
    it { is_expected.to contain_openstacklib__db__mysql('mistral').with(
      'user'          => 'mistral',
      'password_hash' => '*3DDF34A86854A312A8E2C65B506E21C91800D206',
      'dbname'        => 'mistral',
      'host'          => '127.0.0.1',
      'charset'       => 'utf8',
      :collate        => 'utf8_general_ci',
    )}
  end

  describe "overriding allowed_hosts param to array" do
    let :params do
      {
        :password       => 'mistralpass',
        :allowed_hosts  => ['127.0.0.1','%']
      }
    end

  end
  describe "overriding allowed_hosts param to string" do
    let :params do
      {
        :password       => 'mistralpass2',
        :allowed_hosts  => '192.168.1.1'
      }
    end

  end

  describe "overriding allowed_hosts param equals to host param " do
    let :params do
      {
        :password       => 'mistralpass2',
        :allowed_hosts  => '127.0.0.1'
      }
    end

  end

end
