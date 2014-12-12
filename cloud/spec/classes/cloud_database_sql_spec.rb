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
# Unit tests for cloud::database::sql class
#

require 'spec_helper'

describe 'cloud::database::sql' do

  shared_examples_for 'openstack database sql' do

    let :pre_condition do
      "include xinetd"
    end

    let :params do
      {
        :api_eth                        => '10.0.0.1',
        :galera_master_name             => 'os-ci-test1',
        :galera_internal_ips            => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :galera_gcache                  => '1G',
        :keystone_db_host               => '10.0.0.1',
        :keystone_db_user               => 'keystone',
        :keystone_db_password           => 'secrete',
        :keystone_db_allowed_hosts      => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :cinder_db_host                 => '10.0.0.1',
        :cinder_db_user                 => 'cinder',
        :cinder_db_password             => 'secrete',
        :cinder_db_allowed_hosts        => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :glance_db_host                 => '10.0.0.1',
        :glance_db_user                 => 'glance',
        :glance_db_password             => 'secrete',
        :glance_db_allowed_hosts        => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :heat_db_host                   => '10.0.0.1',
        :heat_db_user                   => 'heat',
        :heat_db_password               => 'secrete',
        :heat_db_allowed_hosts          => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :nova_db_host                   => '10.0.0.1',
        :nova_db_user                   => 'nova',
        :nova_db_password               => 'secrete',
        :nova_db_allowed_hosts          => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :neutron_db_host                => '10.0.0.1',
        :neutron_db_user                => 'neutron',
        :neutron_db_password            => 'secrete',
        :neutron_db_allowed_hosts       => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :trove_db_host                  => '10.0.0.1',
        :trove_db_user                  => 'trove',
        :trove_db_password              => 'secrete',
        :trove_db_allowed_hosts         => ['10.0.0.1','10.0.0.2','10.0.0.3'],
        :mysql_root_password            => 'secrete',
        :mysql_sys_maint_password       => 'sys',
        :galera_clustercheck_dbuser     => 'clustercheckuser',
        :galera_clustercheck_dbpassword => 'clustercheckpassword!',
        :galera_clustercheck_ipaddress  => '10.0.0.1'
      }
    end

    it 'configure mysql galera server' do
      is_expected.to contain_class('mysql::client').with(
          :package_name => platform_params[:mysql_client_package_name]
      )

      is_expected.to contain_class('mysql::server').with(
          :package_name     => platform_params[:mysql_server_package_name],
          :override_options => { 'mysqld' => { 'bind-address' => '10.0.0.1' } },
          :notify           => 'Service[xinetd]'
      )

      is_expected.to contain_file(platform_params[:mysql_server_config_file]).with_content(/^wsrep_cluster_name\s*= "galera_cluster"$/)
      is_expected.to contain_file(platform_params[:mysql_server_config_file]).with_content(/^wsrep_node_address\s*= "#{params[:api_eth]}"$/)
      is_expected.to contain_file(platform_params[:mysql_server_config_file]).with_content(/^wsrep_node_incoming_address\s*= "#{params[:api_eth]}"$/)

    end # configure mysql galera server

    context 'configure mysqlchk http replication' do
      it { is_expected.to contain_file('/etc/xinetd.d/mysqlchk').with_mode('0755') }
      it { is_expected.to contain_file('/usr/bin/clustercheck').with_mode('0755') }
      it { is_expected.to contain_file('/usr/bin/clustercheck').with_content(/MYSQL_USERNAME='#{params[:galera_clustercheck_dbuser]}'/)}
      it { is_expected.to contain_file('/usr/bin/clustercheck').with_content(/MYSQL_PASSWORD='#{params[:galera_clustercheck_dbpassword]}'/)}
      it { is_expected.to contain_file('/etc/xinetd.d/mysqlchk').with_content(/bind            = #{params[:galera_clustercheck_ipaddress]}/)}

    end # configure mysqlchk http replication

    context 'configure databases on the galera master server' do

      before :each do
        facts.merge!( :hostname => 'os-ci-test1' )
      end

      it 'configure mysql server' do
        is_expected.to contain_class('mysql::server').with(
            :package_name     => platform_params[:mysql_server_package_name],
            :root_password    => 'secrete',
            :override_options => { 'mysqld' => { 'bind-address' => '10.0.0.1' } },
            :notify           => 'Service[xinetd]'
        )
      end

      it 'configure keystone database' do
        is_expected.to contain_class('keystone::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'keystone',
            :user          => 'keystone',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure glance database' do
        is_expected.to contain_class('glance::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'glance',
            :user          => 'glance',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure nova database' do
        is_expected.to contain_class('nova::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'nova',
            :user          => 'nova',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure cinder database' do
        is_expected.to contain_class('cinder::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'cinder',
            :user          => 'cinder',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure neutron database' do
        is_expected.to contain_class('neutron::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'neutron',
            :user          => 'neutron',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure heat database' do
        is_expected.to contain_class('heat::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'heat',
            :user          => 'heat',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure trove database' do
        is_expected.to contain_class('trove::db::mysql').with(
            :mysql_module  => '2.2',
            :dbname        => 'trove',
            :user          => 'trove',
            :password      => 'secrete',
            :host          => '10.0.0.1',
            :allowed_hosts => ['10.0.0.1','10.0.0.2','10.0.0.3'] )
      end

      it 'configure monitoring database' do
        is_expected.to contain_mysql_database('monitoring').with(
          :ensure   => 'present',
          :charset  => 'utf8'
        )
        is_expected.to contain_mysql_user("#{params[:galera_clustercheck_dbuser]}@localhost").with(
          :ensure        => 'present',
          :password_hash => '*FDC68394456829A7344C2E9D4CDFD43DCE2EFD8F'
        )
        is_expected.to contain_mysql_grant("#{params[:galera_clustercheck_dbuser]}@localhost/monitoring").with(
          :privileges => 'ALL'
        )
      end # configure monitoring database
    end # configure databases on the galera master server

    context 'Bootstrap MySQL database on RedHat plaforms' do
      before :each do
        facts.merge!( :osfamily => 'RedHat' )
      end
      it 'configure mysql database' do
        is_expected.to contain_exec('bootstrap-mysql').with(
          :command => '/usr/bin/mysql_install_db --rpm --user=mysql',
          :unless  => "test -d /var/lib/mysql/mysql",
          :before  => 'Service[mysqld]'
        )
      end
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure mysql firewall rules' do
        is_expected.to contain_firewall('100 allow galera access').with(
          :port   => ['3306', '4567', '4568', '4444'],
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow mysqlchk access').with(
          :port   => '9200',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow mysql rsync access').with(
          :port   => '873',
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
      it 'configure mysql firewall rules with custom parameter' do
        is_expected.to contain_firewall('100 allow galera access').with(
          :port   => ['3306', '4567', '4568', '4444'],
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow mysqlchk access').with(
          :port   => '9200',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow mysql rsync access').with(
          :port   => '873',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end # openstack database sql

  context 'on Debian platforms' do
    let :facts do
      { :osfamily => 'Debian' }
    end

    let :platform_params do
      { :mysql_server_package_name => 'mariadb-galera-server',
        :mysql_client_package_name => 'mariadb-client',
        :mysql_server_config_file => '/etc/mysql/my.cnf',
        :wsrep_provider      => '/usr/lib/galera/libgalera_smm.so' }
    end

    it_configures 'openstack database sql'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily => 'RedHat' }
    end

    let :platform_params do
      { :mysql_server_package_name => 'mariadb-galera-server',
        :mysql_client_package_name => 'mariadb',
        :mysql_server_config_file => '/etc/my.cnf',
        :wsrep_provider      => '/usr/lib64/galera/libgalera_smm.so' }
    end

    it_configures 'openstack database sql'
  end

end
