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
# Unit tests for cloud::loadbalancer class
#

require 'spec_helper'

describe 'cloud::loadbalancer' do

  shared_examples_for 'openstack loadbalancer' do

    let :params do
      { :ceilometer_api                    => true,
        :cinder_api                        => true,
        :glance_api                        => true,
        :neutron_api                       => true,
        :heat_api                          => true,
        :heat_cfn_api                      => true,
        :heat_cloudwatch_api               => true,
        :nova_api                          => true,
        :ec2_api                           => true,
        :metadata_api                      => true,
        :swift_api                         => true,
        :keystone_api_admin                => true,
        :keystone_api                      => true,
        :trove_api                         => true,
        :horizon                           => true,
        :spice                             => true,
        :ceilometer_bind_options           => [],
        :cinder_bind_options               => [],
        :ec2_bind_options                  => [],
        :glance_api_bind_options           => [],
        :glance_registry_bind_options      => [],
        :heat_cfn_bind_options             => [],
        :heat_cloudwatch_bind_options      => [],
        :heat_api_bind_options             => [],
        :keystone_bind_options             => [],
        :keystone_admin_bind_options       => [],
        :metadata_bind_options             => [],
        :neutron_bind_options              => [],
        :trove_bind_options                => [],
        :swift_bind_options                => [],
        :spice_bind_options                => [],
        :horizon_bind_options              => [],
        :galera_bind_options               => [],
        :haproxy_auth                      => 'root:secrete',
        :keepalived_state                  => 'BACKUP',
        :keepalived_priority               => 50,
        :keepalived_vrrp_interface         => false,
        :keepalived_public_interface       => 'eth0',
        :keepalived_public_ipvs            => ['10.0.0.1', '10.0.0.2'],
        :keepalived_internal_ipvs          => false,
        :keepalived_auth_type              => 'PASS',
        :keepalived_auth_pass              => 'secret',
        :horizon_port                      => '80',
        :spice_port                        => '6082',
        :vip_public_ip                     => '10.0.0.1',
        :galera_ip                         => '10.0.0.2',
        :galera_slave                      => false,
        :horizon_ssl                       => false,
        :horizon_ssl_port                  => false,
        :ks_ceilometer_public_port         => '8777',
        :ks_nova_public_port               => '8774',
        :ks_ec2_public_port                => '8773',
        :ks_metadata_public_port           => '8777',
        :ks_glance_api_public_port         => '9292',
        :ks_glance_registry_internal_port  => '9191',
        :ks_swift_public_port              => '8080',
        :ks_keystone_public_port           => '5000',
        :ks_keystone_admin_port            => '35357',
        :ks_cinder_public_port             => '8776',
        :ks_neutron_public_port            => '9696',
        :ks_trove_public_port              => '8779',
        :ks_heat_public_port               => '8004',
        :ks_heat_cfn_public_port           => '8000',
        :ks_heat_cloudwatch_public_port    => '8003' }
    end

    it 'configure haproxy server' do
      is_expected.to contain_class('haproxy')
    end # configure haproxy server

    it 'configure keepalived server' do
      is_expected.to contain_class('keepalived')
    end # configure keepalived server

    it 'configure sysctl to allow HAproxy to bind to a non-local IP address' do
      is_expected.to contain_exec('exec_sysctl_net.ipv4.ip_nonlocal_bind').with_command(
        'sysctl -w net.ipv4.ip_nonlocal_bind=1'
      )
    end

    it 'do not configure an internal VRRP instance by default' do
      is_expected.not_to contain_keepalived__instance('2')
    end

    context 'configure an internal VIP with the same VIP as public network' do
      before do
        params.merge!(:keepalived_internal_ipvs => ['10.0.0.1', '10.0.0.2'])
      end
      it 'shoult not configure an internal VRRP instance' do
        is_expected.not_to contain_keepalived__instance('2')
      end
    end

    context 'configure an internal VIP' do
      before do
        params.merge!(:keepalived_internal_ipvs => ['192.168.0.1'])
      end
      it 'configure an internal VRRP instance' do
        is_expected.to contain_keepalived__instance('2').with({
          'interface'            => 'eth1',
          'virtual_ips'          => ['192.168.0.1 dev eth1'],
          'track_script'         => ['haproxy'],
          'state'                => 'BACKUP',
          'priority'             => params[:keepalived_priority],
          'auth_type'            => 'PASS',
          'auth_pass'            => 'secret',
          'notify_master'        => "#{platform_params[:start_haproxy_service]}",
          'notify_backup'        => "#{platform_params[:stop_haproxy_service]}",
        })
      end
    end

    context 'configure keepalived vrrp on dedicated interface' do
      before do
        params.merge!(:keepalived_vrrp_interface => 'eth2')
      end
      it 'configure keepalived with a dedicated interface for vrrp' do
        is_expected.to contain_keepalived__instance('1').with({
          'interface' => 'eth2',
        })
      end
    end

    context 'configure keepalived with proper haproxy track script' do
      it 'configure keepalived with a proper haproxy track script' do
        is_expected.to contain_keepalived__vrrp_script('haproxy').with({
          'name_is_process' => platform_params[:keepalived_name_is_process],
          'script'          => platform_params[:keepalived_vrrp_script],
        })
      end
    end

    context 'when keepalived and HAproxy are in backup' do
      it 'configure vrrp_instance with BACKUP state' do
        is_expected.to contain_keepalived__instance('1').with({
          'interface'            => params[:keepalived_public_interface],
          'virtual_ips'          => ['10.0.0.1 dev eth0', '10.0.0.2 dev eth0'],
          'track_script'         => ['haproxy'],
          'state'                => params[:keepalived_state],
          'priority'             => params[:keepalived_priority],
          'auth_type'            => 'PASS',
          'auth_pass'            => 'secret',
          'notify_master'        => "#{platform_params[:start_haproxy_service]}",
          'notify_backup'        => "#{platform_params[:stop_haproxy_service]}",
        })
      end # configure vrrp_instance with BACKUP state
      it 'configure haproxy server without service managed' do
        is_expected.to contain_class('haproxy').with(:service_manage => true)
      end # configure haproxy server
    end # configure keepalived in backup

    context 'configure keepalived in master' do
      before do
        params.merge!( :keepalived_state => 'MASTER' )
      end
      it 'configure vrrp_instance with MASTER state' do
        is_expected.to contain_keepalived__instance('1').with({
          'interface'            => params[:keepalived_public_interface],
          'track_script'         => ['haproxy'],
          'state'                => 'MASTER',
          'priority'             => params[:keepalived_priority],
          'auth_type'            => 'PASS',
          'auth_pass'            => 'secret',
          'notify_master'        => "#{platform_params[:start_haproxy_service]}",
          'notify_backup'        => "#{platform_params[:stop_haproxy_service]}",
        })
      end
      it 'configure haproxy server with service managed' do
        is_expected.to contain_class('haproxy').with(:service_manage => true)
      end # configure haproxy server
    end # configure keepalived in master

    context 'configure logrotate file' do
      it { is_expected.to contain_file('/etc/logrotate.d/haproxy').with(
        :source => 'puppet:///modules/cloud/logrotate/haproxy',
        :mode   => '0644',
        :owner  => 'root',
        :group  => 'root'
      )}
    end # configure logrotate file

    context 'configure monitor haproxy listen' do
      it { is_expected.to contain_haproxy__listen('monitor').with(
        :ipaddress => params[:vip_public_ip],
        :ports     => '9300'
      )}
    end # configure monitor haproxy listen

    context 'configure monitor haproxy listen with another vip' do
      before do
        params.merge!( :vip_monitor_ip => ['192.168.0.1'] )
      end
      it { is_expected.to contain_haproxy__listen('monitor').with(
        :ipaddress => ['192.168.0.1'],
        :ports     => '9300'
      )}
    end # configure monitor haproxy listen

    context 'configure galera haproxy listen' do
      it { is_expected.to contain_haproxy__listen('galera_cluster').with(
        :ipaddress => params[:galera_ip],
        :ports     => '3306',
        :options   => {
          'maxconn'        => '1000',
          'mode'           => 'tcp',
          'balance'        => 'roundrobin',
          'option'         => ['tcpka','tcplog','httpchk'],
          'timeout client' => '400s',
          'timeout server' => '400s'
        }
      )}
    end # configure monitor haproxy listen

    context 'not configure galera slave haproxy listen' do
      it { is_expected.not_to contain_haproxy__listen('galera_readonly_cluster') }
    end # configure monitor haproxy listen

    context 'configure galera slave haproxy listen' do
      before do
        params.merge!( :galera_slave => true )
      end
      it { is_expected.to contain_haproxy__listen('galera_readonly_cluster').with(
        :ipaddress => params[:galera_ip],
        :ports     => '3307',
        :options   => {
          'maxconn'        => '1000',
          'mode'           => 'tcp',
          'balance'        => 'roundrobin',
          'option'         => ['tcpka','tcplog','httpchk'],
          'timeout client' => '400s',
          'timeout server' => '400s'
        }
      )}
    end # configure monitor haproxy listen

    # test backward compatibility
    context 'configure OpenStack binding on public network only' do
      it { is_expected.to contain_haproxy__listen('spice_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '6082',
        :options   => {
          'mode'           => 'tcp',
          'balance'        => 'source',
          'option'         => ['tcpka', 'tcplog', 'forwardfor'],
          'timeout server' => '120m',
          'timeout client' => '120m'
        }
      )}
    end

    context 'configure OpenStack binding on both public and internal networks' do
      before do
        params.merge!(
          :nova_api               => true,
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => '172.16.0.1',
          :vip_internal_ip        => '192.168.0.1',
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2'],
          :keepalived_internal_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it { is_expected.to contain_haproxy__listen('nova_api_cluster').with(
        :ipaddress => ['172.16.0.1', '192.168.0.1'],
        :ports     => '8774'
      )}
    end

    context 'configure OpenStack binding on IPv4 and IPv6 public ip' do
      before do
        params.merge!(
          :nova_api               => true,
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => ['172.16.0.1', '2001:0db8:85a3:0000:0000:8a2e:0370:7334'],
          :vip_internal_ip        => '192.168.0.1',
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2', '2001:0db8:85a3:0000:0000:8a2e:0370:7334'],
          :keepalived_internal_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it { is_expected.to contain_haproxy__listen('nova_api_cluster').with(
        :ipaddress => ['172.16.0.1', '2001:0db8:85a3:0000:0000:8a2e:0370:7334', '192.168.0.1'],
        :ports     => '8774'
      )}
    end

    context 'disable an OpenStack service binding' do
      before do
        params.merge!(:metadata_api => false)
      end
      it { is_expected.not_to contain_haproxy__listen('metadata_api_cluster') }
    end

    context 'should fail to configure OpenStack binding when vip_public_ip and vip_internal_ip are missing' do
      before do
        params.merge!(
          :nova_api               => true,
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => false,
          :vip_internal_ip        => false,
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2']
        )
      end
      it_raises 'a Puppet::Error', /vip_public_ip and vip_internal_ip are both set to false, no binding is possible./
    end

    context 'should fail to configure OpenStack binding when given VIP is not in the VIP pool list' do
      before do
        params.merge!(
          :nova_api               => '10.0.0.1',
          :galera_ip              => '172.16.0.1',
          :vip_public_ip          => '172.16.0.1',
          :vip_internal_ip        => false,
          :keepalived_public_ipvs => ['172.16.0.1', '172.16.0.2']
        )
      end
      it_raises 'a Puppet::Error', /10.0.0.1 is not part of VIP pools./
    end

    context 'with a public OpenStack VIP not in the keepalived VIP list' do
      before do
        params.merge!(
          :vip_public_ip          => '172.16.0.1',
          :keepalived_public_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it_raises 'a Puppet::Error', /vip_public_ip should be part of keepalived_public_ipvs./
    end

    context 'with an internal OpenStack VIP not in the keepalived VIP list' do
      before do
        params.merge!(
          :vip_internal_ip          => '172.16.0.1',
          :keepalived_internal_ipvs => ['192.168.0.1', '192.168.0.2']
        )
      end
      it_raises 'a Puppet::Error', /vip_internal_ip should be part of keepalived_internal_ipvs./
    end

    context 'with a Galera VIP not in the keepalived VIP list' do
      before do
        params.merge!(
          :galera_ip                => '172.16.0.1',
          :vip_public_ip            => '192.168.0.1',
          :keepalived_public_ipvs   => ['192.168.0.1', '192.168.0.2'],
          :keepalived_internal_ipvs => ['192.168.1.1', '192.168.1.2']
        )
      end
      it_raises 'a Puppet::Error', /galera_ip should be part of keepalived_public_ipvs or keepalived_internal_ipvs./
    end

    context 'configure OpenStack binding with HTTPS and SSL offloading' do
      before do
        params.merge!(
          :nova_bind_options => ['ssl', 'crt']
        )
      end
      it { is_expected.to contain_haproxy__listen('nova_api_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '8774',
        :options   => {
          'mode'           => 'http',
          'option'         => ['tcpka','forwardfor','tcplog','httpchk'],
          'http-check'     => 'expect ! rstatus ^5',
          'balance'        => 'roundrobin',
        },
        :bind_options => ['ssl', 'crt']
      )}
    end

    context 'configure OpenStack binding with HTTP options' do
      before do
        params.merge!(
          :cinder_bind_options => 'something not secure',
        )
      end
      it { is_expected.to contain_haproxy__listen('cinder_api_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '8776',
        :options   => {
          'mode'           => 'http',
          'option'         => ['tcpka','forwardfor','tcplog', 'httpchk'],
          'http-check'     => 'expect ! rstatus ^5',
          'balance'        => 'roundrobin',
        },
        :bind_options => ['something not secure']
      )}
    end

    context 'configure OpenStack Horizon' do
      it { is_expected.to contain_haproxy__listen('horizon_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '80',
        :options   => {
          'mode'           => 'http',
          'http-check'     => 'expect ! rstatus ^5',
          'option'         => ["tcpka", "forwardfor", "tcplog", "httpchk GET  /#{platform_params[:auth_url]}  \"HTTP/1.0\\r\\nUser-Agent: HAproxy-myhost\""],
          'cookie'         => 'sessionid prefix',
          'balance'        => 'leastconn',
        }
      )}
    end

    context 'configure OpenStack Horizon with SSL termination on HAProxy' do
      before do
        params.merge!(
          :horizon_port         => '443',
          :horizon_ssl          => false,
          :horizon_ssl_port     => false,
          :horizon_bind_options => ['ssl', 'crt']
        )
      end
      it { is_expected.to contain_haproxy__listen('horizon_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '443',
        :options   => {
          'mode'           => 'http',
          'http-check'     => 'expect ! rstatus ^5',
          'option'         => ["tcpka", "forwardfor", "tcplog", "httpchk GET  /#{platform_params[:auth_url]}  \"HTTP/1.0\\r\\nUser-Agent: HAproxy-myhost\""],
          'cookie'         => 'sessionid prefix',
          'balance'        => 'leastconn',
          'reqadd'         => 'X-Forwarded-Proto:\ https if { ssl_fc }'
        },
        :bind_options => ['ssl', 'crt']
      )}
    end

    context 'configure OpenStack Horizon SSL with termination on the webserver' do
      before do
        params.merge!(
          :horizon_ssl      => true,
          :horizon_ssl_port => '443'
        )
      end
      it { is_expected.to contain_haproxy__listen('horizon_ssl_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '443',
        :options   => {
          'mode'           => 'tcp',
          'option'         => ["tcpka", "forwardfor", "tcplog", "ssl-hello-chk"],
          'cookie'         => 'sessionid prefix',
          'balance'        => 'leastconn',
        }
      )}
    end

    context 'configure OpenStack Heat API SSL binding' do
      before do
        params.merge!(
          :heat_api_bind_options => ['ssl', 'crt']
        )
      end
      it { is_expected.to contain_haproxy__listen('heat_api_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '8004',
        :options   => {
          'reqadd'         => 'X-Forwarded-Proto:\ https if { ssl_fc }',
          'mode'           => 'http',
          'option'         => ['tcpka','forwardfor','tcplog', 'httpchk'],
          'http-check'     => 'expect ! rstatus ^5',
          'balance'        => 'roundrobin'
        },
        :bind_options => ['ssl', 'crt']
      )}
    end
    context 'configure RabbitMQ binding' do
      before do
        params.merge!( :rabbitmq => true )
      end
      it { is_expected.to contain_haproxy__listen('rabbitmq_cluster').with(
        :ipaddress => [params[:vip_public_ip]],
        :ports     => '5672',
        :options   => {
          'mode'           => 'tcp',
          'balance'        => 'roundrobin',
          'option'         => ['tcpka', 'tcplog', 'forwardfor'],
        }
      )}
    end

    context 'with default firewall enabled' do
      let :pre_condition do
        "class { 'cloud': manage_firewall => true }"
      end
      it 'configure haproxy firewall rules' do
        # test the firewall rule in cloud::loadbalancer::binding
        is_expected.to contain_firewall('100 allow horizon_cluster binding access').with(
          :port   => '80',
          :proto  => 'tcp',
          :action => 'accept',
        )
        # test the firewall rules in cloud::loadbalancer
        is_expected.to contain_firewall('100 allow galera binding access').with(
          :port   => '3306',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow haproxy monitor access').with(
          :port   => '9300',
          :proto  => 'tcp',
          :action => 'accept',
        )
        is_expected.to contain_firewall('100 allow keepalived access').with(
          :port   => nil,
          :proto  => 'vrrp',
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
      it 'configure haproxy firewall rules with custom parameter' do
        # test the firewall rule in cloud::loadbalancer::binding
        is_expected.to contain_firewall('100 allow horizon_cluster binding access').with(
          :port   => '80',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        # test the firewall rules in cloud::loadbalancer
        is_expected.to contain_firewall('100 allow galera binding access').with(
          :port   => '3306',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow haproxy monitor access').with(
          :port   => '9300',
          :proto  => 'tcp',
          :action => 'accept',
          :limit  => '50/sec',
        )
        is_expected.to contain_firewall('100 allow keepalived access').with(
          :port   => nil,
          :proto  => 'vrrp',
          :action => 'accept',
          :limit  => '50/sec',
        )
      end
    end

  end # shared:: openstack loadbalancer

  context 'on Debian platforms' do
    let :facts do
      { :osfamily       => 'Debian',
        :hostname       => 'myhost' }
    end

    let :platform_params do
      { :auth_url                   => 'horizon',
        :start_haproxy_service      => '"/etc/init.d/haproxy start"',
        :stop_haproxy_service       => '"/etc/init.d/haproxy stop"',
        :keepalived_name_is_process => 'true',
        :keepalived_vrrp_script     => nil,
      }
    end

    it_configures 'openstack loadbalancer'
  end

  context 'on RedHat platforms' do
    let :facts do
      { :osfamily       => 'RedHat',
        :hostname       => 'myhost' }
    end

    let :platform_params do
      { :auth_url                   => 'dashboard',
        :start_haproxy_service      => '"/usr/bin/systemctl start haproxy"',
        :stop_haproxy_service       => '"/usr/bin/systemctl stop haproxy"',
        :keepalived_name_is_process => 'false',
        :keepalived_vrrp_script     => 'systemctl status haproxy.service',
      }
    end

    it_configures 'openstack loadbalancer'
  end

end
