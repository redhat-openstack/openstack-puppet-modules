require 'spec_helper'

describe 'gnocchi' do

  shared_examples 'gnocchi' do

    context 'with default parameters' do
     it 'contains the logging class' do
       is_expected.to contain_class('gnocchi::logging')
     end

      it 'installs packages' do
        is_expected.to contain_package('gnocchi').with(
          :name   => platform_params[:gnocchi_common_package],
          :ensure => 'present',
          :tag    => ['openstack', 'gnocchi-package']
        )
      end
    end
  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Debian' }
    end

    let :platform_params do
      { :gnocchi_common_package => 'gnocchi-common' }
    end

    it_behaves_like 'gnocchi'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :gnocchi_common_package => 'openstack-gnocchi-common' }
    end

    it_behaves_like 'gnocchi'
  end

end
