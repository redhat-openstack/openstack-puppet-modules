require 'spec_helper'

describe 'midonet::midonet_cli' do

  let :pre_condition do
    "class {'midonet::repository':
       midonet_repo            => 'fake',
       midonet_openstack_repo  => 'fake',
       midonet_thirdparty_repo => 'fake',
       midonet_stage           => 'fake',
       openstack_release       => 'fake',
       midonet_key             => '35FEEF2BAD40EA777D0C5BA6FCE340D250F18FCF',
       midonet_key_url         => 'http://repo.midonet.org/packages.midokura.com'
    }"
  end

  let :default_params do
  {
    :api_endpoint => 'http://87.23.43.2:8080/midonet-api',
    :username     => 'midonet',
    :password     => 'dummy',
    :tenant_name  => 'midonet'
  }
  end

  shared_examples_for 'midonet client' do
    let :params do
        {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should have the package installed' do
      is_expected.to contain_package('python-midonetclient')
    end

    it 'should create .midonetrc file' do
      is_expected.to contain_midonet_client_conf('cli/api_url').with_value(params[:api_endpoint])
      is_expected.to contain_midonet_client_conf('cli/username').with_value(params[:username])
      is_expected.to contain_midonet_client_conf('cli/password').with_value(params[:password])
      is_expected.to contain_midonet_client_conf('cli/project_id').with_value(params[:tenant_name])
    end
  end

  context 'on Debian' do
    let :facts do
      {
        :osfamily       => 'Debian',
        :lsbdistrelease => '14.04',
        :lsbdistid      => 'Ubuntu'
      }
    end
    it_configures 'midonet client'
  end

  context 'on RedHat' do
    let :facts do
      {
        :osfamily                  => 'RedHat',
        :operatingsystemmajrelease => 7,
      }
    end
    it_configures 'midonet client'
  end

end
