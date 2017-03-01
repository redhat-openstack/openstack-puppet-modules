require 'spec_helper'

describe 'vswitch::ovs' do

  let :default_params do {
    :package_ensure => 'present',
    :dkms_ensure    => true,
  }
  end

  let :redhat_platform_params do {
    :ovs_package_name      => 'openvswitch',
    :ovs_service_name      => 'openvswitch',
    :provider              => 'ovs_redhat',
  }
  end

  let :debian_platform_params do {
    :ovs_package_name      => 'openvswitch-switch',
    :ovs_dkms_package_name => 'openvswitch-datapath-dkms',
    :ovs_service_name      => 'openvswitch-switch',
    :provider              => 'ovs',
    :service_hasstatus     => false,
    :service_status        => '/etc/init.d/openvswitch-switch status | fgrep "is running"',
  }
  end

  let :ubuntu_platform_params do {
    :ovs_package_name      => 'openvswitch-switch',
    :ovs_dkms_package_name => 'openvswitch-datapath-dkms',
    :ovs_service_name      => 'openvswitch-switch',
    :provider              => 'ovs',
    :service_hasstatus     => false,
    :service_status        => '/sbin/status openvswitch-switch | fgrep "start/running"',
  }
  end

  let :freebsd_platform_params do {
    :ovs_package_name      => 'openvswitch',
    :ovs_service_name      => 'ovs-vswitchd',
    :ovsdb_service_name    => 'ovsdb-server',
    :provider              => 'ovs',
    :service_hasstatus     => nil,
    :ovsdb_hasstatus       => nil,
    :service_status        => '/usr/sbin/service ovs-vswitchd onestatus',
    :ovsdb_status          => '/usr/sbin/service ovsdb-server onestatus',
  }
  end

  shared_examples_for 'vswitch ovs' do
    it 'contains params' do
        is_expected.to contain_class('vswitch::params')
    end

    it 'configures service' do
        is_expected.to contain_service('openvswitch').with(
          :ensure    => true,
          :enable    => true,
          :name      => platform_params[:ovs_service_name],
          :hasstatus => platform_params[:service_hasstatus],
          :status    => platform_params[:service_status],
        )
    end

    it 'install package' do
      is_expected.to contain_package(platform_params[:ovs_package_name]).with(
        :name   => platform_params[:ovs_package_name],
        :ensure => params[:package_ensure],
        :before => 'Service[openvswitch]'
      )
    end
  end

  shared_examples_for 'do not install dkms' do
    it 'does not rebuild kernel module' do
        is_expected.to_not contain_exec('rebuild-ovsmod')
    end
  end

  shared_examples_for 'install dkms' do
    it 'install kernel module' do
      is_expected.to contain_package(platform_params[:ovs_dkms_package_name]).with(
        :name   => platform_params[:ovs_dkms_package_name],
        :ensure => params[:package_ensure],
      )
    end
    it 'rebuilds kernel module' do
        is_expected.to contain_exec('rebuild-ovsmod').with(
          :command     => '/usr/sbin/dpkg-reconfigure openvswitch-datapath-dkms > /tmp/reconf-log',
          :refreshonly => true,
        )
    end
  end

  context 'on redhat with default parameters' do
    let :params do default_params end

    let :facts do
      {:osfamily => 'Redhat'}
    end

    let :platform_params do redhat_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'do not install dkms'
  end

  context 'on redhat with parameters' do
    let :params do {
      :package_ensure => 'latest',
      :dkms_ensure    => false,
    }
    end

    let :facts do
      {:osfamily => 'Redhat'}
    end
    let :platform_params do redhat_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'do not install dkms'
  end

  context 'on Debian with default parameters' do
    let :params do default_params end

    let :facts do
      {:osfamily        => 'Debian',
       :operatingsystem => 'Debian',
      }
    end
    let :platform_params do debian_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'install dkms'
  end

  context 'on Debian with parameters' do
    let :params do {
      :package_ensure => 'latest',
      :dkms_ensure    => false,
    }
    end

    let :facts do
      {:osfamily        => 'Debian',
       :operatingsystem => 'Debian',
      }
    end
    let :platform_params do debian_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'do not install dkms'
  end

  context 'on Ubuntu with default parameters' do
    let :params do default_params end

    let :facts do
      {:osfamily        => 'Debian',
       :operatingsystem => 'ubuntu',
      }
    end
    let :platform_params do ubuntu_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'install dkms'
  end

  context 'on Ubuntu with parameters' do
    let :params do {
      :package_ensure => 'latest',
      :dkms_ensure    => false,
    }
    end

    let :facts do
      {:osfamily        => 'Debian',
       :operatingsystem => 'ubuntu',
      }
    end
    let :platform_params do ubuntu_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'do not install dkms'
  end

  context 'on FreeBSD with default parameters' do
    let :params do default_params end

    let :facts do
      {:osfamily        => 'FreeBSD',
       :operatingsystem => 'FreeBSD',
      }
    end
    let :platform_params do freebsd_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'do not install dkms'

    it 'configures ovsdb service' do
        is_expected.to contain_service('ovsdb-server').with(
          :ensure    => true,
          :enable    => true,
          :name      => platform_params[:ovsdb_service_name],
          :hasstatus => platform_params[:ovsdb_hasstatus],
          :status    => platform_params[:ovsdb_status],
        )
    end
  end

  context 'on FreeBSD with parameters' do
    let :params do {
      :package_ensure => 'latest',
    }
    end

    let :facts do
      {:osfamily        => 'FreeBSD',
       :operatingsystem => 'FreeBSD',
      }
    end
    let :platform_params do freebsd_platform_params end

    it_configures 'vswitch ovs'
    it_configures 'do not install dkms'

    it 'configures ovsdb service' do
        is_expected.to contain_service(platform_params[:ovsdb_service_name]).with(
          :ensure    => true,
          :enable    => true,
          :name      => platform_params[:ovsdb_service_name],
          :hasstatus => platform_params[:ovsdb_hasstatus],
          :status    => platform_params[:ovsdb_status],
        )
    end

    it 'ovs-vswitchd requires ovsdb-server' do
      is_expected.to contain_service(platform_params[:ovsdb_service_name]).that_notifies("Service[#{platform_params[:ovs_package_name]}]")
    end
  end

end
