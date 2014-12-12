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
# Unit tests for cloud::identity class
#

require 'spec_helper'

describe 'cloud::identity' do

  shared_examples_for 'openstack identity' do

    let :params do
      { :identity_roles_addons        => ['SwiftOperator', 'ResellerAdmin'],
        :swift_enabled                => true,
        :keystone_db_host             => '10.0.0.1',
        :keystone_db_user             => 'keystone',
        :keystone_db_password         => 'secrete',
        :ks_admin_email               => 'admin@openstack.org',
        :ks_admin_password            => 'secrete',
        :ks_admin_tenant              => 'admin',
        :ks_admin_token               => 'SECRETE',
        :ks_ceilometer_admin_host     => '10.0.0.1',
        :ks_ceilometer_internal_host  => '10.0.0.1',
        :ks_ceilometer_password       => 'secrete',
        :ks_ceilometer_public_host    => '10.0.0.1',
        :ks_ceilometer_public_port    => '8777',
        :ks_ceilometer_public_proto   => 'https',
        :ks_ceilometer_admin_proto    => 'https',
        :ks_ceilometer_internal_proto => 'https',
        :ks_cinder_admin_host         => '10.0.0.1',
        :ks_cinder_internal_host      => '10.0.0.1',
        :ks_cinder_password           => 'secrete',
        :ks_cinder_public_host        => '10.0.0.1',
        :ks_cinder_public_proto       => 'https',
        :ks_cinder_public_proto       => 'https',
        :ks_cinder_admin_proto        => 'https',
        :ks_glance_admin_host         => '10.0.0.1',
        :ks_glance_internal_host      => '10.0.0.1',
        :ks_glance_password           => 'secrete',
        :ks_glance_public_host        => '10.0.0.1',
        :ks_glance_public_proto       => 'https',
        :ks_glance_admin_proto        => 'https',
        :ks_glance_internal_proto     => 'https',
        :ks_heat_admin_host           => '10.0.0.1',
        :ks_heat_internal_host        => '10.0.0.1',
        :ks_heat_password             => 'secrete',
        :ks_heat_public_host          => '10.0.0.1',
        :ks_heat_public_proto         => 'https',
        :ks_heat_admin_proto          => 'https',
        :ks_heat_internal_proto       => 'https',
        :ks_heat_public_port          => '8004',
        :ks_heat_cfn_public_port      => '8000',
        :ks_keystone_admin_host       => '10.0.0.1',
        :ks_keystone_admin_port       => '35357',
        :ks_keystone_internal_host    => '10.0.0.1',
        :ks_keystone_internal_port    => '5000',
        :ks_keystone_public_host      => '10.0.0.1',
        :ks_keystone_public_port      => '5000',
        :ks_keystone_public_proto     => 'https',
        :ks_keystone_admin_proto      => 'https',
        :ks_keystone_internal_proto   => 'https',
        :ks_neutron_admin_host        => '10.0.0.1',
        :ks_neutron_internal_host     => '10.0.0.1',
        :ks_neutron_password          => 'secrete',
        :ks_neutron_public_host       => '10.0.0.1',
        :ks_neutron_admin_proto       => 'https',
        :ks_neutron_internal_proto    => 'https',
        :ks_neutron_public_proto      => 'https',
        :ks_neutron_public_port       => '9696',
        :ks_nova_admin_host           => '10.0.0.1',
        :ks_nova_internal_host        => '10.0.0.1',
        :ks_nova_password             => 'secrete',
        :ks_nova_public_host          => '10.0.0.1',
        :ks_nova_public_proto         => 'https',
        :ks_nova_internal_proto       => 'https',
        :ks_nova_admin_proto          => 'https',
        :ks_nova_public_port          => '8774',
        :ks_ec2_public_port           => '8773',
        :ks_swift_dispersion_password => 'secrete',
        :ks_swift_internal_host       => '10.0.0.1',
        :ks_swift_password            => 'secrete',
        :ks_swift_public_host         => '10.0.0.1',
        :ks_swift_public_port         => '8080',
        :ks_swift_public_proto        => 'https',
        :ks_swift_admin_proto         => 'https',
        :ks_swift_internal_proto      => 'https',
        :ks_swift_admin_host          => '10.0.0.1',
        :ks_trove_admin_host          => '10.0.0.1',
        :ks_trove_internal_host       => '10.0.0.1',
        :ks_trove_password            => 'secrete',
        :ks_trove_public_host         => '10.0.0.1',
        :ks_trove_public_port         => '8779',
        :ks_trove_public_proto        => 'https',
        :ks_trove_admin_proto         => 'https',
        :ks_trove_internal_proto      => 'https',
        :region                       => 'BigCloud',
        :verbose                      => true,
        :debug                        => true,
        :log_facility                 => 'LOG_LOCAL0',
        :use_syslog                   => true,
        :token_driver                 => 'keystone.token.backends.sql.Token',
        :ks_token_expiration          => '3600',
        :api_eth                      => '10.0.0.1' }
    end

    it 'configure keystone server' do
      is_expected.to contain_class('keystone').with(
        :enabled             => true,
        :admin_token         => 'SECRETE',
        :compute_port        => '8774',
        :debug               => true,
        :verbose             => true,
        :idle_timeout        => '60',
        :log_facility        => 'LOG_LOCAL0',
        :sql_connection      => 'mysql://keystone:secrete@10.0.0.1/keystone?charset=utf8',
        :token_driver        => 'keystone.token.backends.sql.Token',
        :token_provider      => 'keystone.token.providers.uuid.Provider',
        :use_syslog          => true,
        :bind_host           => '10.0.0.1',
        :public_port         => '5000',
        :admin_port          => '35357',
        :token_expiration    => '3600',
        :log_dir             => false,
        :log_file            => false,
        :admin_endpoint      => 'https://10.0.0.1:35357/',
        :public_endpoint     => 'https://10.0.0.1:5000/'
      )
      is_expected.to contain_exec('validate_keystone_connection')
      is_expected.to contain_keystone_config('ec2/driver').with('value' => 'keystone.contrib.ec2.backends.sql.Ec2')
      is_expected.to contain_keystone_config('DEFAULT/log_file').with_ensure('absent')
      is_expected.to contain_keystone_config('DEFAULT/log_dir').with_ensure('absent')
    end

    it 'checks if Keystone DB is populated' do
      is_expected.to contain_exec('keystone_db_sync').with(
        :command => 'keystone-manage db_sync',
        :path    => '/usr/bin',
        :user    => 'keystone',
        :unless  => '/usr/bin/mysql keystone -h 10.0.0.1 -u keystone -psecrete -e "show tables" | /bin/grep Tables'
      )
    end

    it 'configure keystone admin role' do
      is_expected.to contain_class('keystone::roles::admin').with(
        :email        => 'admin@openstack.org',
        :password     => 'secrete',
        :admin_tenant => 'admin'
      )
    end

    # TODO(EmilienM) Disable WSGI - bug #98
    #  it 'configure apache to run keystone with wsgi' do
    #    should contain_class('keystone::wsgi::apache').with(
    #      :servername  => 'keystone.openstack.org',
    #      :admin_port  => '35357',
    #      :public_port => '5000',
    #      :workers     => '2',
    #      :ssl         => false
    #    )
    #  end

    it 'configure keystone endpoint' do
      is_expected.to contain_class('keystone::endpoint').with(
        :public_url   => 'https://10.0.0.1:5000',
        :admin_url    => 'https://10.0.0.1:35357',
        :internal_url => 'https://10.0.0.1:5000',
        :region       => 'BigCloud'
      )
    end

    it 'configure swift endpoints' do
      is_expected.to contain_class('swift::keystone::auth').with(
        :password          => 'secrete',
        :public_address    => '10.0.0.1',
        :public_port       => '8080',
        :public_protocol   => 'https',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :admin_address     => '10.0.0.1',
        :internal_address  => '10.0.0.1',
        :region            => 'BigCloud'
      )
    end

    it 'configure swift dispersion' do
      is_expected.to contain_class('swift::keystone::dispersion').with( :auth_pass => 'secrete' )
    end

    it 'configure ceilometer endpoints' do
      is_expected.to contain_class('ceilometer::keystone::auth').with(
        :admin_address     => '10.0.0.1',
        :internal_address  => '10.0.0.1',
        :password          => 'secrete',
        :port              => '8777',
        :public_address    => '10.0.0.1',
        :public_protocol   => 'https',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :region            => 'BigCloud'
      )
    end

    it 'should not configure trove endpoint by default' do
      is_expected.not_to contain_class('trove::keystone::auth')
    end

    it 'configure nova endpoints' do
      is_expected.to contain_class('nova::keystone::auth').with(
        :admin_address     => '10.0.0.1',
        :cinder            => true,
        :internal_address  => '10.0.0.1',
        :password          => 'secrete',
        :public_address    => '10.0.0.1',
        :public_protocol   => 'https',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :compute_port      => '8774',
        :ec2_port          => '8773',
        :region            => 'BigCloud'
      )
    end

    it 'configure neutron endpoints' do
      is_expected.to contain_class('neutron::keystone::auth').with(
        :admin_address     => '10.0.0.1',
        :internal_address  => '10.0.0.1',
        :password          => 'secrete',
        :public_address    => '10.0.0.1',
        :public_protocol   => 'https',
        :internal_protocol => 'https',
        :admin_protocol    => 'https',
        :port              => '9696',
        :region            => 'BigCloud'
      )
    end

    it 'configure cinder endpoints' do
      is_expected.to contain_class('cinder::keystone::auth').with(
        :admin_address    => '10.0.0.1',
        :internal_address => '10.0.0.1',
        :password         => 'secrete',
        :public_address   => '10.0.0.1',
        :public_protocol  => 'https',
        :region           => 'BigCloud'
      )
    end

    it 'configure glance endpoints' do
      is_expected.to contain_class('glance::keystone::auth').with(
        :admin_address     => '10.0.0.1',
        :internal_address  => '10.0.0.1',
        :password          => 'secrete',
        :public_address    => '10.0.0.1',
        :public_protocol   => 'https',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :port              => '9292',
        :region            => 'BigCloud'
      )
    end

    it 'configure heat endpoints' do
      is_expected.to contain_class('heat::keystone::auth').with(
        :admin_address     => '10.0.0.1',
        :internal_address  => '10.0.0.1',
        :password          => 'secrete',
        :public_address    => '10.0.0.1',
        :public_protocol   => 'https',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :port              => '8004',
        :region            => 'BigCloud'
      )
    end

    it 'configure heat cloudformation endpoints' do
      is_expected.to contain_class('heat::keystone::auth_cfn').with(
        :admin_address     => '10.0.0.1',
        :internal_address  => '10.0.0.1',
        :password          => 'secrete',
        :public_address    => '10.0.0.1',
        :public_protocol   => 'https',
        :admin_protocol    => 'https',
        :internal_protocol => 'https',
        :port              => '8000',
        :region            => 'BigCloud'
      )
    end

    it 'configure a crontab to purge tokens every days at midnight' do
      is_expected.to contain_class('keystone::cron::token_flush')
    end

    context 'without syslog' do
      before :each do
        params.merge!(:use_syslog => false)
      end
      it 'configure keystone server' do
        is_expected.to contain_class('keystone').with(
          :use_syslog          => false,
          :log_dir             => '/var/log/keystone',
          :log_file            => 'keystone.log'
        )
      end
    end

    context 'without Swift' do
      before :each do
        params.merge!(:swift_enabled => false)
      end
      it 'should not configure swift endpoints and users' do
        is_expected.not_to contain_class('swift::keystone::auth')
        is_expected.not_to contain_class('swift::keystone::dispersion')
      end
    end

    context 'with Trove' do
      before :each do
        params.merge!(:trove_enabled => true)
      end
      it 'configure trove endpoints' do
        is_expected.to contain_class('trove::keystone::auth').with(
          :admin_address     => '10.0.0.1',
          :internal_address  => '10.0.0.1',
          :password          => 'secrete',
          :port              => '8779',
          :public_address    => '10.0.0.1',
          :public_protocol   => 'https',
          :admin_protocol    => 'https',
          :internal_protocol => 'https',
          :region            => 'BigCloud'
        )
      end
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure keystone firewall rules' do
        is_expected.to contain_firewall('100 allow keystone access').with(
          :port   => '5000',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow keystone admin access').with(
          :port   => '35357',
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
      it 'configure keystone firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow keystone access').with(
          :port   => '5000',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow keystone admin access').with(
          :port   => '35357',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end

  context 'on Debian platforms' do
    let :facts do
      { :osfamily               => 'Debian',
        :operatingsystemrelease => '12.04',
        :processorcount         => '2',
        :fqdn                   => 'keystone.openstack.org' }
    end

    it_configures 'openstack identity'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily               => 'RedHat',
        :operatingsystemrelease => '6',
        :processorcount         => '2',
        :fqdn                   => 'keystone.openstack.org' }
    end

    it_configures 'openstack identity'
  end

end
