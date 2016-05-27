require 'spec_helper'

describe 'pacemaker::new::resource::route', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      let(:title) { 'my-route' }

      context 'with default parameters' do

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__resource__route('my-route') }

        parameters = {
            :ensure => 'present',
            :primitive_type => 'Route',
            :primitive_provider => 'heartbeat',
            :primitive_class => 'ocf',
            :parameters => {},
        }

        it { is_expected.to contain_pacemaker_resource('route-my-route').with(parameters) }

      end

      context 'with custom parameters' do

        let(:params) do
          {
              :ensure => 'absent',
              :device => 'eth0',
              :source => '192.168.0.2',
              :additional => {'device' => 'eth1'},
              :destination => '172.16.0.1',
              :gateway => '192.168.0.1',
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
              :primitive_type => 'route',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_pacemaker__new__resource__route('my-route') }

        parameters = {
            :ensure => 'absent',
            :primitive_class => 'ocf',
            :primitive_provider => 'my',
            :primitive_type => 'route',
            :parameters => {
                'device' => 'eth1',
                'source' => '192.168.0.2',
                'destination' => '172.16.0.1',
                'gateway' => '192.168.0.1',
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

        it { is_expected.to contain_pacemaker_resource('route-my-route').with(parameters) }
      end

    end
  end
end

