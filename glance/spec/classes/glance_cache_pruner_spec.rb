require 'spec_helper'

describe 'glance::cache::pruner' do

  shared_examples_for 'glance cache pruner' do

    context 'when default parameters' do

      it 'configures a cron' do
         is_expected.to contain_cron('glance-cache-pruner').with(
          :command     => 'glance-cache-pruner ',
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin',
          :user        => 'glance',
          :minute      => '*/30',
          :hour        => '*',
          :monthday    => '*',
          :month       => '*',
          :weekday     => '*'
        )
        is_expected.to contain_cron('glance-cache-pruner').with(
          :require => "Package[#{platform_params[:api_package_name]}]"
        )
      end
    end

    context 'when overriding parameters' do
      let :params do
        {
          :minute           => 59,
          :hour             => 23,
          :monthday         => '1',
          :month            => '2',
          :weekday          => '3',
          :command_options  => '--config-dir /etc/glance/',
        }
      end
      it 'configures a cron' do
        is_expected.to contain_cron('glance-cache-pruner').with(
          :command     => 'glance-cache-pruner --config-dir /etc/glance/',
          :environment => 'PATH=/bin:/usr/bin:/usr/sbin',
          :user        => 'glance',
          :minute      => 59,
          :hour        => 23,
          :monthday    => '1',
          :month       => '2',
          :weekday     => '3'
        )
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts())
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          { :api_package_name => 'glance-api' }
        when 'RedHat'
          { :api_package_name => 'openstack-glance' }
        end
      end

      it_configures 'glance cache pruner'
    end
  end
end
