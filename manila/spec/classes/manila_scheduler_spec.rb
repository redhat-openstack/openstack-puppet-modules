require 'spec_helper'

describe 'manila::scheduler' do

  describe 'on debian platforms' do

    let :facts do
      { :osfamily => 'Debian' }
    end

    describe 'with default parameters' do

      it { is_expected.to contain_class('manila::params') }

      it { is_expected.to contain_package('manila-scheduler').with(
        :name      => 'manila-scheduler',
        :ensure    => 'present',
        :before    => 'Service[manila-scheduler]'
      ) }

      it { is_expected.to contain_service('manila-scheduler').with(
        :name      => 'manila-scheduler',
        :enable    => true,
        :ensure    => 'running',
        :require   => 'Package[manila]',
        :hasstatus => true
      ) }
    end

    describe 'with parameters' do

      let :params do
        { :scheduler_driver => 'manila.scheduler.filter_scheduler.FilterScheduler',
          :package_ensure   => 'present'
        }
      end

      it { is_expected.to contain_manila_config('DEFAULT/scheduler_driver').with_value('manila.scheduler.filter_scheduler.FilterScheduler') }
      it { is_expected.to contain_package('manila-scheduler').with_ensure('present') }
    end

    describe 'with manage_service false' do
      let :params do
        { 'manage_service' => false
        }
      end
      it 'should not change the state of the service' do
        is_expected.to contain_service('manila-scheduler').without_ensure
      end
    end
  end


  describe 'on rhel platforms' do

    let :facts do
      { :osfamily => 'RedHat' }
    end

    describe 'with default parameters' do

      it { is_expected.to contain_class('manila::params') }

      it { is_expected.to contain_service('manila-scheduler').with(
        :name    => 'openstack-manila-scheduler',
        :enable  => true,
        :ensure  => 'running',
        :require => 'Package[manila]'
      ) }
    end

    describe 'with parameters' do

      let :params do
        { :scheduler_driver => 'manila.scheduler.filter_scheduler.FilterScheduler' }
      end

      it { is_expected.to contain_manila_config('DEFAULT/scheduler_driver').with_value('manila.scheduler.filter_scheduler.FilterScheduler') }
    end
  end
end
