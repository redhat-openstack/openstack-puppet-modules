require 'spec_helper'

describe 'pacemaker::new::resource::ip', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:title) { 'my-ip' }

      context 'with default parameters' do

        let(:params) do
          {
              :ip_address => '192.168.0.1',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__resource__ip('my-ip') }

        parameters = {
            :ensure => 'present',
            :primitive_type => 'IPaddr2',
            :primitive_provider => 'heartbeat',
            :primitive_class => 'ocf',
            :parameters => {
                'ip' => '192.168.0.1',
                'cidr_netmask' => '32',
            },
        }

        it { is_expected.to contain_pacemaker_resource('ip-192.168.0.1').with(parameters) }

      end

      context 'with custom parameters' do

        let(:params) do
          {
              :ensure => 'absent',
              :ip_address => '2001:db8::',
              :nic => 'eth0',
              :additional => {'nic' => 'eth1'},
              :cidr_netmask => '64',
              :metadata => {
                  'resource-stickiness' => '200',
              },
              :operations => {
                  'monitor' => {
                      'interval' => '10',
                  },
              },
              :primitive_class => 'ocf',
              :primitive_provider => 'my',
              :primitive_type => 'ip',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__resource__ip('my-ip') }

        parameters = {
            :ensure => 'absent',
            :primitive_type => 'ip',
            :primitive_provider => 'my',
            :primitive_class => 'ocf',
            :parameters => {
                'ip' => '2001:db8::',
                'cidr_netmask' => '64',
                'nic' => 'eth1',
            },
            :metadata => {
                'resource-stickiness' => '200',
            },
            :operations => {
                'monitor' => {
                    'interval' => '10',
                },
            },
        }

        it { is_expected.to contain_pacemaker_resource('ip-2001.db8..').with(parameters) }
      end

      context 'with the incorrect ip_address' do
        let(:params) do
          {
              :ip_address => 'my-ip',
          }
        end

        it 'should fail' do
          expect do
            is_expected.to compile.with_all_deps
          end.to raise_error /not a valid IP address/
        end

      end

      context 'with the incorrect cidr_netmask' do
        let(:params) do
          {
              :ip_address => '192.168.0.1',
              :cidr_netmask => 'my-mask',
          }
        end

        it 'should fail' do
          expect do
            is_expected.to compile.with_all_deps
          end.to raise_error /argument to be an Integer/
        end
      end

    end
  end
end

