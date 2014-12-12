#
# Copyright (C) 2014 eNovance SAS <licensing@enovance.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Unit tests for cloud::compute::hypervisor class
#

require 'spec_helper'

describe 'cloud::compute::hypervisor' do

  shared_examples_for 'openstack compute hypervisor' do

    let :pre_condition do
      "class { 'cloud::compute':
        availability_zone       => 'MyZone',
        nova_db_host            => '10.0.0.1',
        nova_db_user            => 'nova',
        nova_db_password        => 'secrete',
        rabbit_hosts            => ['10.0.0.1'],
        rabbit_password         => 'secrete',
        ks_glance_internal_host => '10.0.0.1',
        glance_api_port         => '9292',
        verbose                 => true,
        debug                   => true,
        use_syslog              => true,
        neutron_protocol        => 'http',
        neutron_endpoint        => '10.0.0.1',
        neutron_region_name     => 'MyRegion',
        neutron_password        => 'secrete',
        memcache_servers        => ['10.0.0.1','10.0.0.2'],
        log_facility            => 'LOG_LOCAL0' }
       class { 'cloud::telemetry':
        ceilometer_secret          => 'secrete',
        rabbit_hosts               => ['10.0.0.1'],
        rabbit_password            => 'secrete',
        ks_keystone_internal_host  => '10.0.0.1',
        ks_keystone_internal_port  => '5000',
        ks_keystone_internal_proto => 'http',
        ks_ceilometer_password     => 'secrete',
        log_facility               => 'LOG_LOCAL0',
        use_syslog                 => true,
        verbose                    => true,
        debug                      => true }
       class { 'cloud::network':
        rabbit_hosts             => ['10.0.0.1'],
        rabbit_password          => 'secrete',
        api_eth                  => '10.0.0.1',
        verbose                  => true,
        debug                    => true,
        use_syslog               => true,
        dhcp_lease_duration      => '10',
        log_facility             => 'LOG_LOCAL0' }"
    end

    let :params do
      { :libvirt_type                         => 'kvm',
        :server_proxyclient_address           => '7.0.0.1',
        :spice_port                           => '6082',
        :nova_ssh_private_key                 => 'secrete',
        :nova_ssh_public_key                  => 'public',
        :ks_nova_public_proto                 => 'http',
        :ks_spice_public_proto                => 'https',
        :ks_spice_public_host                 => '10.0.0.2',
        :vm_rbd                               => false,
        :volume_rbd                           => false,
        :nova_shell                           => false,
        :ks_nova_public_host                  => '10.0.0.1' }
    end

    it 'configure nova common' do
      is_expected.to contain_class('nova').with(
          :verbose                 => true,
          :debug                   => true,
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0',
          :rabbit_userid           => 'nova',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :memcached_servers       => ['10.0.0.1','10.0.0.2'],
          :database_connection     => 'mysql://nova:secrete@10.0.0.1/nova?charset=utf8',
          :glance_api_servers      => 'http://10.0.0.1:9292',
          :log_dir                 => false,
          :nova_shell              => '/bin/bash'
        )
      is_expected.to contain_nova_config('DEFAULT/resume_guests_state_on_host_boot').with('value' => true)
      is_expected.to contain_nova_config('DEFAULT/default_availability_zone').with('value' => 'MyZone')
      is_expected.to contain_nova_config('DEFAULT/servicegroup_driver').with_value('mc')
      is_expected.to contain_nova_config('DEFAULT/glance_num_retries').with_value('10')
    end

    it 'configure neutron on compute node' do
      is_expected.to contain_class('nova::network::neutron').with(
          :neutron_admin_password => 'secrete',
          :neutron_admin_auth_url => 'http://10.0.0.1:35357/v2.0',
          :neutron_region_name    => 'MyRegion',
          :neutron_url            => 'http://10.0.0.1:9696'
      )
    end

    it 'configure ceilometer common' do
      is_expected.to contain_class('ceilometer').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'ceilometer',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :metering_secret         => 'secrete',
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0'
        )
      is_expected.to contain_class('ceilometer::agent::auth').with(
          :auth_password => 'secrete',
          :auth_url      => 'http://10.0.0.1:5000/v2.0'
      )
    end

    it 'configure neutron common' do
      is_expected.to contain_class('neutron').with(
          :allow_overlapping_ips   => true,
          :dhcp_agents_per_network => '2',
          :verbose                 => true,
          :debug                   => true,
          :log_facility            => 'LOG_LOCAL0',
          :use_syslog              => true,
          :rabbit_user             => 'neutron',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :rabbit_virtual_host     => '/',
          :bind_host               => '10.0.0.1',
          :core_plugin             => 'neutron.plugins.ml2.plugin.Ml2Plugin',
          :service_plugins         => ['neutron.services.loadbalancer.plugin.LoadBalancerPlugin','neutron.services.metering.metering_plugin.MeteringPlugin','neutron.services.l3_router.l3_router_plugin.L3RouterPlugin'],
          :log_dir                 => false,
          :report_interval         => '30'
      )
    end

    it 'configure neutron on compute node' do
      is_expected.to contain_class('nova::network::neutron').with(
          :neutron_admin_password => 'secrete',
          :neutron_admin_auth_url => 'http://10.0.0.1:35357/v2.0',
          :neutron_region_name    => 'MyRegion',
          :neutron_url            => 'http://10.0.0.1:9696'
      )
    end

    it 'configure ceilometer common' do
      is_expected.to contain_class('ceilometer').with(
          :verbose                 => true,
          :debug                   => true,
          :rabbit_userid           => 'ceilometer',
          :rabbit_hosts            => ['10.0.0.1'],
          :rabbit_password         => 'secrete',
          :metering_secret         => 'secrete',
          :use_syslog              => true,
          :log_facility            => 'LOG_LOCAL0'
        )
      is_expected.to contain_class('ceilometer::agent::auth').with(
          :auth_password => 'secrete',
          :auth_url      => 'http://10.0.0.1:5000/v2.0'
        )
    end

    it 'checks if Nova DB is populated' do
      is_expected.to contain_exec('nova_db_sync').with(
        :command => 'nova-manage db sync',
        :path    => '/usr/bin',
        :user    => 'nova',
        :unless  => '/usr/bin/mysql nova -h 10.0.0.1 -u nova -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure nova-compute' do
      is_expected.to contain_class('nova::compute').with(
          :enabled                       => true,
          :vnc_enabled                   => false,
          :virtio_nic                    => false,
          :neutron_enabled               => true
        )
    end

    it 'configure spice console' do
      is_expected.to contain_class('nova::compute::spice').with(
          :server_listen              => '0.0.0.0',
          :server_proxyclient_address => '7.0.0.1',
          :proxy_host                 => '10.0.0.2',
          :proxy_protocol             => 'https',
          :proxy_port                 => '6082'
        )
    end

    it 'configure nova compute with neutron' do
      is_expected.to contain_class('nova::compute::neutron')
    end

    it 'configure ceilometer agent compute' do
      is_expected.to contain_class('ceilometer::agent::compute')
    end

    it 'do not configure nova shell' do
      is_expected.not_to contain_user('nova')
    end

    it 'should not configure nova-compute for RBD backend' do
      is_expected.not_to contain_nova_config('libvirt/rbd_user').with('value' => 'cinder')
      is_expected.not_to contain_nova_config('libvirt/images_type').with('value' => 'rbd')
    end

    it 'configure libvirt driver without disk cachemodes' do
      is_expected.to contain_class('nova::compute::libvirt').with(
          :libvirt_type      => 'kvm',
          :vncserver_listen  => '0.0.0.0',
          :migration_support => true,
          :libvirt_disk_cachemodes => []
        )
    end

    it 'configure nova-compute with extra parameters' do
      is_expected.to contain_nova_config('DEFAULT/default_availability_zone').with('value' => 'MyZone')
      is_expected.to contain_nova_config('libvirt/inject_key').with('value' => false)
      is_expected.to contain_nova_config('libvirt/inject_partition').with('value' => '-2')
      is_expected.to contain_nova_config('libvirt/live_migration_flag').with('value' => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_PERSIST_DEST')
      is_expected.to contain_nova_config('libvirt/block_migration_flag').with('value' => 'VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_NON_SHARED_INC')
    end

    context 'with dbus on Ubuntu' do
      let :facts do
        { :osfamily        => 'Debian',
          :operatingsystem => 'Ubuntu',
          :vtx             => true,
        }
      end

      it 'ensure dbus is running and started at boot' do
        is_expected.to contain_service('dbus').with(
          :ensure => 'running',
          :enable => 'true'
        )
      end
    end

    context 'without TSO/GSO/GRO on Debian systems' do
      before :each do
        facts.merge!( :osfamily         => 'Debian',
                      :operatingsystem  => 'Debian',
                      :vtx              => true  )
      end
      it 'ensure TSO script is enabled at boot' do
        is_expected.to contain_exec('enable-tso-script').with(
          :command => '/usr/sbin/update-rc.d disable-tso defaults',
          :unless  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
      it 'start TSO script' do
        is_expected.to contain_exec('start-tso-script').with(
          :command => '/etc/init.d/disable-tso start',
          :unless  => '/usr/bin/test -f /var/run/disable-tso.pid',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
    end

    context 'without TSO/GSO/GRO on Red Hat systems' do
      before :each do
        facts.merge!( :osfamily         => 'RedHat',
                      :vtx              => true )
      end
      it 'ensure TSO script is enabled at boot' do
        is_expected.to contain_exec('enable-tso-script').with(
          :command => '/usr/sbin/chkconfig disable-tso on',
          :unless  => '/bin/ls /etc/rc*.d | /bin/grep disable-tso',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
      it 'start TSO script' do
        is_expected.to contain_exec('start-tso-script').with(
          :command => '/etc/init.d/disable-tso start',
          :unless  => '/usr/bin/test -f /var/run/disable-tso.pid',
          :onlyif  => '/usr/bin/test -f /etc/init.d/disable-tso'
        )
      end
    end

    context 'when not managing TSO/GSO/GRO' do
      before :each do
        params.merge!( :manage_tso => false)
      end
      it 'ensure TSO script is not managed at boot' do
        is_expected.not_to contain_exec('enable-tso-script')
      end
      it 'do not start TSO script' do
        is_expected.not_to contain_exec('start-tso-script')
      end
    end

    context 'when managing nova shell' do
      before :each do
        params.merge!( :nova_shell => '/bin/bash')
      end
      it 'ensure nova shell is configured by Puppet' do
        is_expected.to contain_user('nova').with(
          :ensure     => 'present',
          :system     => true,
          :home       => '/var/lib/nova',
          :managehome => false,
          :shell      => '/bin/bash'
        )
      end
    end

    context 'with RBD backend for instances and volumes' do
      before :each do
        facts.merge!( :vtx => true )
        params.merge!(
          :vm_rbd               => true,
          :volume_rbd           => true,
          :cinder_rbd_user      => 'cinder',
          :nova_rbd_pool        => 'nova',
          :nova_rbd_secret_uuid => 'secrete' )
      end

      it 'configure nova-compute to support RBD backend' do
        is_expected.to contain_nova_config('libvirt/images_type').with('value' => 'rbd')
        is_expected.to contain_nova_config('libvirt/images_rbd_pool').with('value' => 'nova')
        is_expected.to contain_nova_config('libvirt/images_rbd_ceph_conf').with('value' => '/etc/ceph/ceph.conf')
        is_expected.to contain_nova_config('libvirt/rbd_user').with('value' => 'cinder')
        is_expected.to contain_nova_config('libvirt/rbd_secret_uuid').with('value' => 'secrete')
        is_expected.to contain_group('cephkeyring').with(:ensure => 'present')
        is_expected.to contain_exec('add-nova-to-group').with(
          :command => 'usermod -a -G cephkeyring nova',
          :unless  => 'groups nova | grep cephkeyring'
        )
      end

      it 'configure libvirt driver' do
        is_expected.to contain_class('nova::compute::libvirt').with(
            :libvirt_type      => 'kvm',
            :vncserver_listen  => '0.0.0.0',
            :migration_support => true,
            :libvirt_disk_cachemodes => ['network=writeback']
          )
      end
    end

    context 'with RBD support only for volumes' do
      before :each do
        facts.merge!( :vtx => true )
        params.merge!(
          :vm_rbd               => false,
          :volume_rbd           => true,
          :cinder_rbd_user      => 'cinder',
          :nova_rbd_secret_uuid => 'secrete' )
      end

      it 'configure nova-compute to support RBD backend' do
        is_expected.not_to contain_nova_config('libvirt/images_type').with('value' => 'rbd')
        is_expected.not_to contain_nova_config('libvirt/images_rbd_pool').with('value' => 'nova')
        is_expected.to contain_nova_config('libvirt/rbd_user').with('value' => 'cinder')
        is_expected.to contain_nova_config('libvirt/rbd_secret_uuid').with('value' => 'secrete')
        is_expected.to contain_group('cephkeyring').with(:ensure => 'present')
        is_expected.to contain_exec('add-nova-to-group').with(
          :command => 'usermod -a -G cephkeyring nova',
          :unless  => 'groups nova | grep cephkeyring'
        )
      end

      it 'configure libvirt driver' do
        is_expected.to contain_class('nova::compute::libvirt').with(
            :libvirt_type      => 'kvm',
            :vncserver_listen  => '0.0.0.0',
            :migration_support => true,
            :libvirt_disk_cachemodes => ['network=writeback']
          )
      end
    end

    context 'when trying to enable RBD backend on RedHat OSP < 7 plaforms' do
      before :each do
        facts.merge!( :osfamily                  => 'RedHat',
                      :operatingsystemmajrelease => '6' )
        params.merge!(
          :vm_rbd               => true,
          :cinder_rbd_user      => 'cinder',
          :nova_rbd_pool        => 'nova',
          :nova_rbd_secret_uuid => 'secrete' )
      end
      it_raises 'a Puppet::Error', /RBD image backend in Nova is not supported in RHEL 6./
    end

    context 'when running KVM libvirt driver without VTX enabled' do
      before :each do
        facts.merge!( :vtx => false )
      end
      it_raises 'a Puppet::Error', /libvirt_type is set to KVM and VTX seems to be disabled on this node./
    end

    context 'when storing instances on a NFS share' do
      before :each do
        params.merge!(
          :nfs_enabled => true,
          :nfs_device  => 'nfs.example.com:/vol1',
          :nfs_options => 'noacl,fsid=123' )
      end
      it 'configure nova instances path and NFS mount' do
        is_expected.to contain_nova_config('DEFAULT/instances_path').with('value' => '/var/lib/nova/instances')
        is_expected.to contain_mount('/var/lib/nova/instances').with({
          'ensure'  => 'mounted',
          'fstype'  => 'nfs',
          'device'  => 'nfs.example.com:/vol1',
          'options' => 'noacl,fsid=123'
        })
      end
    end

    context 'when storing instances on a NFS share without nfs_device' do
      before :each do
        params.merge!(
          :nfs_enabled => true,
          :nfs_device  => false )
      end
      it_raises 'a Puppet::Error', /When running NFS backend, you need to provide nfs_device parameter./
    end

    context 'when storing instances on a NFS share with vm_rbd enabled' do
      before :each do
        params.merge!(
          :nfs_enabled => true,
          :vm_rbd      => true,
          :nfs_device  => 'nfs.example.com:/vol1' )
      end
      it_raises 'a Puppet::Error', /When running NFS backend, vm_rbd parameter cannot be set to true./
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure compute firewall rules' do
        is_expected.to contain_firewall('100 allow instances console access').with(
          :port   => '5900-5999',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow instances migration access').with(
          :port   => ['16509', '49152-49215'],
          :proto  => 'tcp',
          :action => 'accept',
        )
      end
    end

    context 'with custom firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      before :each do
        params.merge!(:firewall_settings => { 'limit' => '50/sec' } )
      end
      it 'configure compute firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow instances console access').with(
          :port   => '5900-5999',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow instances migration access').with(
          :port   => ['16509', '49152-49215'],
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

 end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :vtx             => true,
        # required for rpcbind module
        :lsbdistid       => 'Debian'
      }
    end

    it_configures 'openstack compute hypervisor'
    it { should contain_file_line('/etc/default/libvirtd libvirtd opts').with(:line => 'libvirtd_opts="-d -l"') }
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily                  => 'RedHat',
        :vtx                       => true,
        # required for rbd support check
        :operatingsystemmajrelease => '7',
        # required for nfs module
        :lsbmajdistrelease         => '7'
      }
    end

    it_configures 'openstack compute hypervisor'
    it { should contain_file_line('/etc/sysconfig/libvirtd libvirtd args').with(:line => 'LIBVIRTD_ARGS="--listen"') }
  end

end
